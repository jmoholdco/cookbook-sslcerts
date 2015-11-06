require 'chef/dsl/recipe'
require 'chef/dsl/data_query'

class Chef
  class Provider
    class CaCertificate < Chef::Provider
      include SSLCertsCookbook::Helpers
      include SSLCertsCookbook::Mixin::Provider
      include Chef::DSL::Recipe

      attr_reader :on_disk, :in_vault, :request_generator

      def load_current_resource
        @current_resource ||= Chef::Resource::CaCertificate.new(
          @new_resource.name
        )
        @current_resource.ca_path new_resource.ca_path
        current_resource_request_generator
        @on_disk = true if ca_exists?
        @in_vault = true if ca_in_vault?
        @request_generator = current_resource.request_generator
        @current_resource
      end

      def action_create # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        return if @on_disk
        do_create_directory_structure
        do_write_private_key

        if new_resource.type == 'root'
          do_write_certificate(request_generator.private_key.to_pem)
        else
          do_handle_csr
        end

        file new_resource.serial_filename do
          owner new_resource.owner
          group new_resource.group
          mode '0644'
          sensitive true
          content current_resource.request_generator.serial.export
        end
      end

      protected

      def do_handle_csr
        return unless current_resource.request_generator.request
        if request_signed?
          certbag = load_certbag
          do_write_certificate(certbag['certificate'])
          node.set['csr_outbox'].delete(new_resource.cert_id)
        else
          do_write_csr
        end
      end

      def do_write_certificate(pem_content)
        file new_resource.certificate_filename do
          owner 'root'
          group node['root_group']
          mode '0644'
          sensitive true
          content pem_content
        end
      end

      def do_create_directory_structure
        directory new_resource.ca_path do
          recursive true
        end

        %W(
          #{new_resource.ca_path}/private
          #{new_resource.ca_path}/certs
          #{new_resource.ca_path}/csr
        ).each do |dir|
          directory dir do
            recursive true
          end
        end
      end
    end
  end
end
