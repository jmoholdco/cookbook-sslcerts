require 'chef/resource'

class Chef
  class Resource
    class CaCertificate < Chef::Resource
      include SSLCertsCookbook::Mixin::Resource

      def initialize(name, run_context = nil)
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
          kind_of: String,
          default: lazy { "#{ssl_dir}/CA" }
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

      def serial_filename(arg = nil)
        set_or_return(
          :serial_filename,
          arg,
          kind_of: String
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
    end
  end
end
