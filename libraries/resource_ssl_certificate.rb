require 'chef/resource'
require 'digest/sha2'

class Chef
  class Resource
    class SslCertificate < Chef::Resource
      include SSLCertsCookbook::Mixin::Resource

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
      alias_method :province, :state

      def ssl_dir_for_platform
        case node['platform_family']
        when 'rhel', 'fedora' then '/etc/pki/tls'
        else '/etc/ssl'
        end
      end

      def default_common_name
        node['fqdn']
      end
    end
  end
end
