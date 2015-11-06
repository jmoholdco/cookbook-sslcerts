require 'chef/resource'
require 'digest/sha2'

class Chef
  class Resource
    class SslCertificate < Chef::Resource
      include SSLCertsCookbook::Mixin::Resource
      state_attrs :cert_id
      attr_writer :cert_id
      attr_reader :full_certname

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

      def full_certname(arg = nil)
        set_or_return(
          :full_certname,
          arg,
          kind_of: String,
          default: lazy { _filename }
        )
      end

      def default_common_name
        return name unless run_context
        run_context.node.fqdn
      end

      private

      def lazy_filename_for(file_type)
        case file_type
        when :request then "#{ssl_dir}/csr/#{_filename}.pem"
        when :private_key then "#{ssl_dir}/private/#{_filename}.pem"
        when :certificate then "#{ssl_dir}/certs/#{_filename}.pem"
        end
      end

      def _filename
        return name if name == safe_node_attr('fqdn')
        "#{name}-#{safe_node_attr('fqdn')}"
      end

      def generate_cert_id
        Digest::SHA256.new.update(_filename).to_s
      end
    end
  end
end
