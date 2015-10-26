require 'chef/mixin/shell_out'
require 'chef/dsl/recipe'
require 'chef/dsl/data_query'

class Chef
  class Provider
    class SslCertificate < Chef::Provider
      include SSLCertsCookbook::Mixin::Provider
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

      def generated_csr
        @csr ||= EaSSL::SigningRequest.new(
          key: generated_private_key,
          name: EaSSL::CertificateName.new(gen_certname(new_resource))
        )
      end

      def certificate_exists?
        ::File.exist?(new_resource.certificate_filename)
      end
    end
  end
end
# rubocop:enable All
