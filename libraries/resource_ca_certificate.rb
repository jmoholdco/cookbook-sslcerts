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
          :name,
          arg,
          kind_of: String,
          required: true
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

      alias_method :province, :state

      def subject_alt_names(arg = nil)
        set_or_return(
          :subject_alt_names,
          arg,
          kind_of: Array
        )
      end

      def private_key_filename(arg = nil)
        set_or_return(
          :private_key_file,
          arg,
          kind_of: String
        )
      end

      def certificate_filename(arg = nil)
        set_or_return(
          :private_key_file,
          arg,
          kind_of: String
        )
      end

      def serial_filename(arg = nil)
        set_or_return(
          :private_key_file,
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

      def save_in_vault?(arg = nil)
        set_or_return(
          :save_in_vault?,
          arg,
          kind_of: [TrueClass, FalseClass],
          equal_to: [true, false],
          default: true
        )
      end

      def ca_cert_path
        return "#{ca_path}/certs/cacert.pem" unless certificate_filename
        "#{ca_path}/certs/#{certificate_filename}"
      end

      def private_key_path
        return "#{ca_path}/private/cakey.pem" unless private_key_filename
        "#{ca_path}/private/#{private_key_filename}"
      end

      def ca_serial_path
        return "#{ca_path}/serial" unless serial_filename
        "#{ca_path}/#{serial_filename}"
      end

      def ca_csr_path
        "#{ca_path}/csr/ca_csr.pem"
      end

      alias_method :type, :authority_type

      private

      def default_common_name
        name
      end
    end
  end
end
