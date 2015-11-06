require 'chef/dsl/platform_introspection'
require_relative 'mixin_cert_request'

module SSLCertsCookbook
  module Mixin
    # This is a mixin module to provide shared behavior between all custom
    # resources in this cookbook.
    module Provider
      include Chef::DSL::Recipe
      include SSLCertsCookbook::Helpers
      include SSLCertsCookbook::Mixin::CertRequest::Provider
      include Chef::DSL::DataQuery
      include Chef::DSL::PlatformIntrospection

      def self.included(base)
        base.class_eval do
          attr_accessor :request_outbox
          attr_reader :private_key
        end
      end

      def do_write_private_key # rubocop:disable Metrics/AbcSize
        return if private_key_exists?
        file new_resource.private_key_filename do
          owner new_resource.owner
          group new_resource.group
          mode '0400'
          sensitive true
          content current_resource.request_generator.private_key_pem
        end
      end

      def do_write_csr # rubocop:disable Metrics/AbcSize
        return if csr_exists?
        file new_resource.request_filename do
          owner new_resource.owner
          group new_resource.group
          mode '0644'
          sensitive true
          content current_resource.request_generator.request_pem
        end
        return if node['csr_outbox'] && outbox_match?
        add_request_to_outbox(request_generator.request_pem)
      end

      def current_resource_request_generator
        load_current_resource_request
        current_resource.request_generator = load_generated_request
      end

      def add_request_to_outbox(outbox)
        node.set['csr_outbox'][current_resource.cert_id] =
          generate_outbox_hash(outbox)
      end

      def generate_outbox_hash(request)
        {
          id: new_resource.cert_id,
          csr: request,
          date: Time.now.to_s,
          type: new_resource.type,
          days: new_resource.days,
          signed: false,
          hostname: node['fqdn'],
          certificate_name: new_resource.full_certname
        }
      end

      def csr_cache_path
        File.join(Chef::Config[:file_cache_path], 'csr_outbox')
      end

      def load_generated_request
        return new_request_generator unless key_and_csr_exist?
        SSL::Utils::RequestGenerator.load(new_resource)
      end

      def new_request_generator
        SSL::Utils::RequestGenerator.new(new_resource)
      end

      def verify_certificate!(certificate, key)
        SSL::Utils::CertKeyVerifier.new(certificate, key).verify!
      end
    end
  end
end
