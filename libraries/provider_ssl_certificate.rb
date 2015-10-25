require 'chef/mixin/shell_out'
require 'chef/dsl/recipe'
require 'chef/dsl/data_query'
require 'chef/sugar'

class Chef
  class Provider
    class SslCertificate < Chef::Provider
      include Chef::DSL::Recipe
      include Chef::Mixin::ShellOut
      include SSLCertsCookbook::Helpers
      include Chef::DSL::DataQuery
      include Chef::Sugar::DSL
      include Chef::DSL::Recipe

      def load_current_resource
        @current_resource ||= Chef::Resource::SslCertificate.new(
          @new_resource.name
        )
        @current_resource
      end

      def action_create
        create_directory_structure
        generate_request unless certificate_exists?
        create_signed_cert if request_signed?
      end

      protected

      def create_directory_structure
        %W(
          #{new_resource.ssl_dir}
          #{new_resource.ssl_dir}/private
          #{new_resource.ssl_dir}/csr
          #{new_resource.ssl_dir}/certs
        ).each do |d|
          directory "#{d}" do
            recursive true
          end
        end
      end

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def generate_request
        private_key = generated_private_key.private_key
        csr = generated_csr

        file new_resource.private_key_filename do
          owner 'root'
          group node['root_group']
          mode '0400'
          sensitive true
          content private_key.to_pem
        end

        file new_resource.request_filename do
          owner 'root'
          group node['root_group']
          mode '0644'
          sensitive true
          content csr.to_pem
        end

        add_request_to_outbox unless node['csr_outbox'] &&
                                     node['csr_outbox'][new_resource.cert_id]
      end

      def create_signed_cert # rubocop:disable Metrics/AbcSize
        certbag = load_certbag
        file new_resource.certificate_filename do
          owner 'root'
          group node['root_group']
          mode '0644'
          sensitive true
          content certbag['certificate']
        end
        node.set['csr_outbox'].delete(new_resource.cert_id)
      end

      def add_request_to_outbox
        node.set['csr_outbox'][new_resource.cert_id] = {
          id: new_resource.cert_id,
          csr: generated_csr.to_pem,
          date: Time.now.to_s,
          type: new_resource.type,
          days: new_resource.days,
          signed: false,
          hostname: node['fqdn']
        }
      end

      def generated_private_key
        @private_key ||= if ::File.exist?(new_resource.private_key_filename)
                           load_rsa_key(
                             new_resource.private_key_filename,
                             new_resource.key_password
                           )
                         else
                           gen_rsa(new_resource.bits, new_resource.key_password)
                         end
      end

      def generated_csr
        @csr ||= EaSSL::SigningRequest.new(
          key: generated_private_key,
          name: EaSSL::CertificateName.new(gen_certname(new_resource))
        )
      end

      def certificate_exists?
        ::File.exist?(new_resource.certificate_filename)
      end

      def request_generated?
        node.attribute?('csr_outbox') && node['csr_outbox'][new_resource.cert_id]
      end

      def request_signed?
        request_generated? && load_certbag
      end

      def load_certbag
        data_bag_item('certificates', new_resource.cert_id)
      rescue => e
        Chef::Log.error('Couldnt find the certificate in the data bag.')
        Chef::Log.error("New resource cert_id: #{new_resource.cert_id}")
        Chef::Log.error(e.message)
        Chef::Log.info(e)
      end
    end
  end
end
# rubocop:enable All
