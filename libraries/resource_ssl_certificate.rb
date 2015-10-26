require 'chef/resource'
require 'digest/sha2'

class Chef
  class Resource
    class SslCertificate < Chef::Resource
      include SSLCertsCookbook::Mixin::Resource
      state_attrs :cert_id
      attr_writer :cert_id

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

      def type(arg = nil)
        set_or_return(
          :type,
          arg,
          kind_of: String,
          equal_to: %w(server client subordinate),
          default: 'server'
        )
      end

      def default_common_name
        node['fqdn']
      end
    end
  end
end
