require 'chef/mixin/shell_out'
require 'chef/dsl/recipe'
require 'chef/dsl/data_query'

class Chef
  class Provider
    class SslCertificate < Chef::Provider
      include SSLCertsCookbook::Mixin::Provider
      include SSLCertsCookbook::Mixin::Serialization
      include Chef::DSL::Recipe

      attr_accessor :existing_request
      def load_current_resource # rubocop:disable Metrics/MethodLength
        @current_resource ||= Chef::Resource::SslCertificate.new(
          @new_resource.name
        )
        shared_current_resource_loading
        @existing_request =
          if ::File.exist?("#{csr_cache_path}/#{new_resource.name}")
            load_serialized_request_outbox
          elsif key_and_csr_exist?
            load_request_from_components
          end
        @current_resource
      end

      def action_create
        create_directory_structure
        generate_request unless certificate_exists? || existing_request

        update_outbox if existing_request && !outbox_match?
        create_signed_cert if request_signed?
      end

      protected

      def key_and_csr_exist?
        ::File.exist?(current_resource.private_key_filename) &&
          ::File.exist?(current_resource.request_filename)
      end

      def create_directory_structure
        %W(
          #{csr_cache_path}
          #{current_resource.ssl_dir}
          #{current_resource.ssl_dir}/private
          #{current_resource.ssl_dir}/csr
          #{current_resource.ssl_dir}/certs
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
        file_group = resource_group
        file_owner = current_resource.owner

        file current_resource.private_key_filename do
          owner file_owner
          group file_group
          mode '0400'
          sensitive true
          content private_key.to_pem
        end

        file current_resource.request_filename do
          owner file_owner
          group file_group
          mode '0644'
          sensitive true
          content csr.to_pem
        end

        add_request_to_outbox(csr) unless node['csr_outbox'] && outbox_match?
      end

      def update_outbox
        add_request_to_outbox(existing_request.csr)
      end

      def create_signed_cert # rubocop:disable Metrics/AbcSize
        certbag = load_certbag
        file_owner = current_resource.owner
        file_group = resource_group
        file current_resource.certificate_filename do
          owner file_owner
          group file_group
          mode '0644'
          sensitive true
          content certbag['certificate']
        end
        node.set['csr_outbox'].delete(current_resource.cert_id)
      end

      def generated_csr
        @csr ||= EaSSL::SigningRequest.new(
          key: generated_private_key,
          name: EaSSL::CertificateName.new(gen_certname(new_resource)),
          type: new_resource.type
        )
      end

      def certificate_exists?
        ::File.exist?(current_resource.certificate_filename)
      end

      def lazy_filename_for(file_type)
        filename = if new_resource.name == node['fqdn']
                     current_resource.name
                   else
                     "#{current_resource.name}-#{node['fqdn']}"
                   end
        case file_type
        when :request then "#{ssl_dir}/csr/#{filename}.pem"
        when :private_key
          "#{ssl_dir}/private/#{filename}.pem"
        when :certificate
          "#{ssl_dir}/certs/#{filename}.pem"
        when :cert_id then filename
        end
      end

      def ssl_dir
        return new_resource.ssl_dir if new_resource.ssl_dir
        return current_resource.ssl_dir if current_resource.ssl_dir
        ssl_dir_for_platform
      end
    end
  end
end
# rubocop:enable All
