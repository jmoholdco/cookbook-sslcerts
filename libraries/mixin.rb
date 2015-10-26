require 'chef/dsl/platform_introspection'

module SSLCertsCookbook
  module Mixin
    module Resource # rubocop:disable Metrics/ModuleLength
      def self.included(base)
        base.class_eval do
          alias_method :province, :state
        end
      end

      def cert_id(arg = nil)
        set_or_return(
          :cert_id,
          arg,
          kind_of: String,
          regex: /[a-f0-9]{64}/
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

      def ssl_dir(arg = nil)
        set_or_return(
          :ssl_dir,
          arg,
          kind_of: String
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
          default: lazy { default_common_name }
        )
      end

      def subject_alt_names(arg = nil)
        set_or_return(
          :subject_alt_names,
          arg,
          kind_of: Array
        )
      end

      def request_filename(arg = nil)
        set_or_return(
          :request_filename,
          arg,
          kind_of: String
        )
      end

      def private_key_filename(arg = nil)
        set_or_return(
          :private_key_filename,
          arg,
          kind_of: String
        )
      end

      def certificate_filename(arg = nil)
        set_or_return(
          :certificate_filename,
          arg,
          kind_of: String
        )
      end
    end

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

      def shared_current_resource_loading # rubocop:disable Metrics/AbcSize
        current_resource.private_key_filename lazy_filename_for(:private_key)
        current_resource.request_filename lazy_filename_for(:request)
        current_resource.certificate_filename lazy_filename_for(:certificate)
        current_resource.cert_id create_cert_id(lazy_filename_for(:cert_id))
        current_resource.ssl_dir(new_resource.ssl_dir || ssl_dir_for_platform)
      end

      def create_cert_id(cert_id)
        Digest::SHA256.new.update(cert_id).to_s
      end

      def add_request_to_outbox(outbox)
        node.set['csr_outbox'][new_resource.cert_id] =
          generate_outbox_hash(outbox)
      end

      def request_outbox
        @request_outbox ||= OpenStruct.new(
          generate_outbox_hash(generated_csr)
        )
      end

      def generate_outbox_hash(request)
        {
          id: new_resource.cert_id,
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
        node['csr_outbox'][new_resource.cert_id] == request_outbox
      end

      def load_certbag
        data_bag_item('certificates', current_resource.cert_id)
      rescue => e
        Chef::Log.error('Couldnt find the certificate in the data bag.')
        Chef::Log.error("New resource cert_id: #{new_resource.cert_id}")
        Chef::Log.error(e.message)
        Chef::Log.info(e)
        nil
      end

      def csr_cache_path
        File.join(Chef::Config[:file_cache_path], 'csr_outbox')
      end

      def ssl_dir_for_platform
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
          req.key = EaSSL::Key.load(new_resource.private_key_filename)
          req.csr = EaSSL::SigningRequest.load(new_resource.request_filename)
        end
      end
    end
  end
end
