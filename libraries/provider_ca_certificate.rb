require 'chef/mixin/shell_out'
require 'chef/dsl/recipe'

class Chef
  class Provider
    class CaCertificate < Chef::Provider
      include Chef::DSL::Recipe
      include Chef::Mixin::ShellOut
      include SSLCertsCookbook::Helpers
      include Chef::DSL::Recipe

      def load_current_resource
        @current_resource ||= Chef::Resource::CaCertificate.new(
          @new_resource.name
        )
        @on_disk = true if ca_exists?
        @in_vault = true if ca_in_vault?
        @current_resource
      end

      def action_create # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        return if @on_disk
        create_directory_structure
        key = generated_ca.key
        cert = generated_ca.certificate
        serial = generated_ca.serial

        file new_resource.private_key_path do
          owner 'root'
          group node['root_group']
          mode '0400'
          sensitive true
          content key.to_pem
        end

        file new_resource.ca_cert_path do
          owner 'root'
          group node['root_group']
          mode '0644'
          sensitive true
          content cert.to_pem
        end

        file new_resource.ca_serial_path do
          owner 'root'
          group node['root_group']
          mode '0644'
          sensitive true
          content serial.export
        end
      end

      protected

      def generated_private_key
        @genpkey ||= gen_rsa(new_resource.bits, new_resource.key_password)
      end

      def generated_certificate
        @gencert ||= EaSSL::AuthorityCertificate.new(
          key: generated_private_key,
          name: certname
        )
      end

      def generated_serial
        @gser ||= EaSSL::Serial.new(next: 1, path: new_resource.ca_serial_path)
      end

      def generated_ca
        @generated_ca ||= if new_resource.authority_type == 'root'
                            generate_self_signed
                          else
                            generate_ca_csr
                          end
      end

      def certname
        @certname ||= gen_certname(new_resource)
      end

      def create_directory_structure
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

      def generate_self_signed
        EaSSL::CertificateAuthority.new(
          key: generated_private_key,
          certificate: generated_certificate,
          serial: generated_serial
        )
      end

      def generate_ca_csr
      end
    end
  end
end
