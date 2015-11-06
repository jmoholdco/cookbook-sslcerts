require 'chef/dsl/recipe'
require 'chef/dsl/data_query'

class Chef
  class Provider
    class SslCertificate < Chef::Provider
      include SSLCertsCookbook::Mixin::Provider
      include Chef::DSL::Recipe

      attr_accessor :existing_request, :request_generator
      def load_current_resource
        @current_resource ||= Chef::Resource::SslCertificate.new(
          @new_resource.name, run_context
        )
        current_resource_request_generator
        do_current_resource_pem_content
        @request_generator = current_resource.request_generator
        @current_resource
      end

      def action_create
        do_create_directory_structure
        do_write_private_key
        do_write_csr
        do_write_certificate
      end

      def do_create_directory_structure
        %W(
          #{csr_cache_path}
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
      def do_write_certificate
        return if certificate_exists?
        return unless request_signed?
        certbag = load_certbag
        verify_certificate!(
          certbag['certificate'], current_resource.private_key_pem
        )
        file new_resource.certificate_filename do
          owner new_resource.owner
          group new_resource.group
          mode '0644'
          sensitive true
          content certbag['certificate']
        end
        node.set['csr_outbox'].delete(new_resource.cert_id)
      end

      def update_outbox
        add_request_to_outbox(existing_request.csr)
      end
    end
  end
end
# rubocop:enable All
