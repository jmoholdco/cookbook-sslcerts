require 'chef/resource'
require 'digest/sha2'

class Chef
  class Resource
    class CaCertificate < Chef::Resource
      include SSLCertsCookbook::Mixin::Resource

      def initialize(name, run_context = nil)
        @ca_path ||= default_ca_path_for_platform
        super
        @resource_name = :ca_certificate
        @action = :create
        @allowed_actions.push :create
        @allowed_actions.push :sync
        @provider = Chef::Provider::CaCertificate
      end

      def name(arg = nil)
        set_or_return(
          :name,
          arg,
          kind_of: String,
          regex: /[\w+.-]+/,
          name_attribute: true,
          required: true
        )
      end

      def ca_path(arg = nil)
        set_or_return(
          :ca_path,
          arg,
          kind_of: String
        )
      end

      def ca_name(arg = nil)
        set_or_return(
          :ca_name,
          arg,
          kind_of: String,
          default: lazy { name.gsub(/\s+/, '_').downcase }
        )
      end

      alias_method :full_certname, :ca_name

      def serial_filename(arg = nil)
        set_or_return(
          :serial_filename,
          arg,
          kind_of: String,
          default: lazy { lazy_filename_for(:serial) }
        )
      end

      def authority_type(arg = nil)
        set_or_return(
          :authority_type,
          arg,
          kind_of: String,
          equal_to: %w(root intermediate),
          default: 'root'
        )
      end

      def save_in_vault(arg = nil)
        set_or_return(
          :save_in_vault,
          arg,
          equal_to: [true, false],
          default: true
        )
      end

      alias_method :ca_cert_path, :certificate_filename
      alias_method :private_key_path, :private_key_filename
      alias_method :ca_serial_path, :serial_filename
      alias_method :ca_csr_path, :request_filename
      alias_method :type, :authority_type

      private

      def default_common_name
        name
      end

      def lazy_filename_for(file_type)
        case file_type
        when :request then "#{ca_path}/csr/ca_csr.pem"
        when :private_key then "#{ca_path}/private/cakey.pem"
        when :certificate then "#{ca_path}/certs/cacert.pem"
        when :serial then "#{ca_path}/serial"
        end
      end

      def default_ca_path_for_platform
        case safe_node_attr('platform_family')
        when 'rhel', 'fedora' then '/etc/pki/CA'
        else '/etc/ssl/CA'
        end
      end

      def generate_cert_id
        Digest::SHA256.new.update(ca_name).to_s
      end
    end
  end
end
