require 'chef/dsl/platform_introspection'

module SSLCertsCookbook
  module Mixin
    # This is a mixin module to provide shared behavior between all custom
    # resources in this cookbook.
    module Provider
      include Chef::DSL::Recipe
      include Chef::Mixin::ShellOut
      include SSLCertsCookbook::Helpers
      include Chef::DSL::DataQuery
      include Chef::DSL::PlatformIntrospection

      def self.included(base)
        base.class_eval do
          attr_accessor :request_outbox
          attr_reader :private_key
        end
      end

      def shared_current_resource_loading
        current_resource.private_key_filename lazy_filename_for(:private_key)
        current_resource.request_filename lazy_filename_for(:request)
        current_resource.certificate_filename lazy_filename_for(:certificate)
        # current_resource.cert_id create_cert_id(lazy_filename_for(:cert_id))
        current_resource.ssl_dir(new_resource.ssl_dir || ssl_dir_for_platform)
      end

      def resource_group
        current_resource.group || node['root_group']
      end

      def create_cert_id(cert_id)
        Digest::SHA256.new.update(cert_id).to_s
      end

      def add_request_to_outbox(outbox)
        node.set['csr_outbox'][current_resource.cert_id] =
          generate_outbox_hash(outbox)
      end

      def request_outbox
        @request_outbox ||= OpenStruct.new(
          generate_outbox_hash(generated_csr)
        )
      end

      def generate_outbox_hash(request)
        {
          id: current_resource.cert_id,
          csr: request.to_pem,
          date: Time.now.to_s,
          type: new_resource.type,
          days: new_resource.days,
          signed: false,
          hostname: node['fqdn'],
          certificate_name: lazy_filename_for(:cert_id)
        }
      end

      def generated_private_key
        @private_key ||= if ::File.exist?(current_resource.private_key_filename)
                           load_rsa_key(
                             current_resource.private_key_filename,
                             current_resource.key_password
                           )
                         else
                           gen_rsa(current_resource.bits,
                                   current_resource.key_password)
                         end
      end

      def request_generated?
        node.attribute?('csr_outbox') &&
          node['csr_outbox'][current_resource.cert_id]
      end

      def request_signed?
        request_generated? && load_certbag
      end

      def outbox_match?
        node.attribute?('csr_outbox') &&
          node['csr_outbox'][current_resource.cert_id] == request_outbox.to_h
      end

      def load_certbag
        data_bag_item('certificates', current_resource.cert_id)
      rescue => e
        Chef::Log.error("Couldn't find the certificate in the data bag.")
        Chef::Log.error("New resource cert_id: #{new_resource.cert_id}")
        Chef::Log.error(e.message)
        Chef::Log.info(e)
        nil
      end

      def csr_cache_path
        File.join(Chef::Config[:file_cache_path], 'csr_outbox')
      end

      def ssl_dir_for_platform
        return current_resource.ssl_dir if current_resource.ssl_dir
        value_for_platform_family(
          'rhel' => '/etc/pki/tls',
          'fedora' => '/etc/pki/tls',
          'default' => '/etc/ssl'
        )
      end
    end

    module Serialization
      def self.included(_base)
        require 'yaml' unless defined?(YAML)
      end

      def serialize_request_outbox
        return unless request_outbox
        ::File.open("#{csr_cache_path}/#{new_resource.name}", 'w') do |io|
          io.write request_outbox.to_yaml
        end
      end

      def load_serialized_request_outbox
        @request_outbox =
          YAML.load_file("#{csr_cache_path}/#{new_resource.name}")
      end

      def load_request_from_components
        OpenStruct.new.tap do |req|
          req.key = EaSSL::Key.load(current_resource.private_key_filename)
          req.csr = EaSSL::SigningRequest.load current_resource.request_filename
        end
      end
    end
  end
end
