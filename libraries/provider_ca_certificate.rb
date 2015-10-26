require 'chef/mixin/shell_out'
require 'chef/dsl/recipe'
require 'chef/dsl/data_query'
require 'ostruct'

class Chef
  class Provider
    class CaCertificate < Chef::Provider # rubocop:disable Metrics/ClassLength
      include SSLCertsCookbook::Helpers
      include SSLCertsCookbook::Mixin::Provider
      include Chef::DSL::Recipe

      def load_current_resource # rubocop:disable Metrics/AbcSize,MethodLength
        @current_resource ||= Chef::Resource::CaCertificate.new(
          @new_resource.name
        )
        shared_current_resource_loading
        current_resource.serial_filename lazy_filename_for(:serial)
        if new_resource.ca_path
          current_resource.ca_path(new_resource.ca_path)
        elsif current_resource.ssl_dir
          current_resource.ca_path("#{current_resource.ssl_dir}/CA")
        else
          current_resource.ca_path('/etc/ssl/ca')
        end
        @on_disk = true if ca_exists?
        @in_vault = true if ca_in_vault?
        @current_resource
      end

      def action_create # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        return if @on_disk
        create_directory_structure
        key = generated_ca.key
        serial = generated_ca.serial

        file current_resource.private_key_filename do
          owner 'root'
          group node['root_group']
          mode '0400'
          sensitive true
          content key.to_pem
        end

        write_certificate_to_disk
        handle_csr

        file current_resource.serial_filename do
          owner 'root'
          group node['root_group']
          mode '0644'
          sensitive true
          content serial.export
        end
      end

      protected

      def write_certificate_to_disk
        return unless (cert = generated_ca.certificate)
        file current_resource.ca_cert_path do
          owner 'root'
          group node['root_group']
          mode '0644'
          sensitive true
          content cert.to_pem
        end
      end

      def handle_csr # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        return unless generated_ca.is_a?(OpenStruct)
        if request_signed?
          certbag = load_certbag
          file current_resource.ca_cert_path do
            owner 'root'
            group node['root_group']
            mode '0644'
            sensitive true
            content certbag['certificate']
          end
          node.set['csr_outbox'].delete(new_resource.cert_id)
        else
          csr_content = generated_ca.csr
          file current_resource.ca_csr_path do
            owner 'root'
            group node['root_group']
            mode '0644'
            sensitive true
            content csr_content.to_pem
          end
          add_request_to_outbox(csr_content)
        end
      end

      def generated_csr
        return unless generated_ca.is_a?(OpenStruct)
        generated_ca.csr
      end

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
        @gser ||= EaSSL::Serial.new(next: 1,
                                    path: current_resource.ca_serial_path)
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
        directory current_resource.ca_path do
          recursive true
        end

        %W(
          #{current_resource.ca_path}/private
          #{current_resource.ca_path}/certs
          #{current_resource.ca_path}/csr
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
        OpenStruct.new.tap do |t|
          t.key = generated_private_key
          t.name = EaSSL::CertificateName.new(certname)
          t.csr = EaSSL::SigningRequest.new(name: t.name, key: t.key)
          t.serial = generated_serial
          t.certificate = nil
        end
      end

      def lazy_filename_for(file_type)
        case file_type
        when :request then "#{new_resource.ca_path}/csr/ca_csr.pem"
        when :private_key then "#{new_resource.ca_path}/private/cakey.pem"
        when :certificate then "#{new_resource.ca_path}/certs/cacert.pem"
        when :serial then "#{new_resource.ca_path}/serial"
        when :cert_id then new_resource.name
        end
      end
    end
  end
end
