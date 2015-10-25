require 'chef/resource'

class Chef
  class Resource
    class CaCertificate < Chef::Resource # rubocop:disable Metrics/ClassLength
      def initialize(name, run_context = nil)
        super
        @resource_name = :ca_certificate
        @action = :create
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

      def key_password(arg = nil)
        set_or_return(
          :key_password,
          arg,
          kind_of: String,
          required: true
        )
      end

      def bits(arg = nil)
        set_or_return(
          :bits,
          arg,
          kind_of: Fixnum,
          equal_to: [2048, 4096, 8192],
          default: 8192
        )
      end

      def days(arg = nil)
        set_or_return(
          :days,
          arg,
          kind_of: Fixnum,
          default: (365 * 10)
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

      def organization(arg = nil)
        set_or_return(
          :organization,
          arg,
          kind_of: String,
          required: true
        )
      end

      def organizational_unit(arg = nil)
        set_or_return(
          :organizational_unit,
          arg,
          kind_of: String
        )
      end

      def country(arg = nil)
        set_or_return(
          :country,
          arg,
          kind_of: String,
          regex: /^[A-Z]{2}$/,
          default: 'US'
        )
      end

      def state(arg = nil)
        set_or_return(
          :state,
          arg,
          kind_of: String
        )
      end

      alias_method :province, :state

      def common_name(arg = nil)
        set_or_return(
          :common_name,
          arg,
          kind_of: String,
          required: true
        )
      end

      def subject_alt_names(arg = nil)
        set_or_return(
          :subject_alt_names,
          arg,
          kind_of: Array
        )
      end

      def private_key_file(arg = nil)
        set_or_return(
          :private_key_file,
          arg,
          kind_of: String
        )
      end

      def certificate_file(arg = nil)
        set_or_return(
          :private_key_file,
          arg,
          kind_of: String
        )
      end

      def serial_file(arg = nil)
        set_or_return(
          :private_key_file,
          arg,
          kind_of: String
        )
      end

      def ca_cert_path
        return "#{ca_path}/certs/cacert.pem" unless certificate_file
        "#{ca_path}/certs/#{private_key_file}"
      end

      def private_key_path
        return "#{ca_path}/private/cakey.pem" unless private_key_file
        "#{ca_path}/private/#{private_key_file}"
      end

      def ca_serial_path
        return "#{ca_path}/serial" unless serial_file
        "#{ca_path}/#{serial_file}"
      end
    end
  end
end
