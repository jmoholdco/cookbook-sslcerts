require 'chef/resource'
require 'digest/sha2'

class Chef
  class Resource
    class SslCertificate < Chef::Resource # rubocop:disable Metrics/ClassLength
      def initialize(name, run_context = nil)
        super
        @resource_name = :ssl_certificate
        @action = :create
        @allowed_actions.push :create
        @provider = Chef::Provider::SslCertificate
      end

      def name(arg = nil)
        set_or_return(
          :name,
          arg,
          kind_of: String,
          name_attribute: true,
          required: true
        )
      end

      def ssl_dir(arg = nil)
        set_or_return(
          :ssl_dir,
          arg,
          kind_of: String,
          default: ssl_dir_for_platform
        )
      end

      def type(arg = nil)
        set_or_return(
          :type,
          arg,
          kind_of: String,
          equal_to: %w(server client subordinate),
          default: 'server'
        )
      end

      def bits(arg = nil)
        set_or_return(
          :bits,
          arg,
          kind_of: Fixnum,
          equal_to: [1024, 2048, 4096, 8192],
          default: 2048
        )
      end

      def days(arg = nil)
        set_or_return(
          :days,
          arg,
          kind_of: Fixnum,
          default: (365 * 5)
        )
      end

      def key_password(arg = nil)
        set_or_return(
          :key_password,
          arg,
          kind_of: [String, NilClass],
          default: nil
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

      def city(arg = nil)
        set_or_return(
          :city,
          arg,
          kind_of: String
        )
      end

      def common_name(arg = nil)
        set_or_return(
          :common_name,
          arg,
          kind_of: String,
          default: lazy { node['fqdn'] }
        )
      end

      def subject_alt_names(arg = nil)
        set_or_return(
          :subject_alt_names,
          arg,
          kind_of: Array
        )
      end

      def ssl_dir_for_platform
        case node['platform_family']
        when 'rhel', 'fedora' then '/etc/pki/tls'
        else '/etc/ssl'
        end
      end

      def cert_id
        Digest::SHA256.new.update(name).to_s
      end

      def request_filename(arg = nil)
        set_or_return(
          :request_filename,
          arg,
          kind_of: String,
          default: lazy { lazy_filename_for(:request) }
        )
      end

      def private_key_filename(arg = nil)
        set_or_return(
          :private_key_filename,
          arg,
          kind_of: String,
          default: lazy { lazy_filename_for(:private_key) }
        )
      end

      def certificate_filename(arg = nil)
        set_or_return(
          :certificate_filename,
          arg,
          kind_of: String,
          default: lazy { lazy_filename_for(:certificate) }
        )
      end

      private

      def lazy_filename_for(file_type)
        filename = name == node['fqdn'] ? name : "#{name}-#{node['fqdn']}"
        case file_type
        when :request then "#{ssl_dir}/csr/#{filename}.pem"
        when :private_key then "#{ssl_dir}/private/#{filename}.pem"
        when :certificate then "#{ssl_dir}/certs/#{filename}.pem"
        end
      end
    end
  end
end
