$LOAD_PATH.unshift(
  *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
)

require 'eassl'
require 'eassl_overrides'
require 'ssl'

module SSLCertsCookbook
  module Helpers
    def self.included(_base)
      require 'openssl' unless defined?(OpenSSL)
    end

    def ca_exists?
      return unless defined?(:new_resource)
      File.exist?(new_resource.certificate_filename)
    end

    def ca_in_vault?
      return unless defined?(:new_resource)
      true if ca_vault_item(new_resource.ca_name)
    end

    def ca_vault_item(ca_name)
      chef_vault_item(:cacerts, ca_name)
    rescue => e
      Chef::Log.info('Error loading the CA from the vault')
      Chef::Log.info("Your parameters were: :cacerts, #{new_resource.ca_name}")
      Chef::Log.info(e)
      nil
    end

    def request_generated?
      node.attribute?('csr_outbox') &&
        node['csr_outbox'][new_resource.cert_id]
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
      Chef::Log.info("Couldn't find the certificate in the data bag.")
      Chef::Log.info("New resource cert_id: #{new_resource.cert_id}")
      Chef::Log.info(e.message)
      Chef::Log.info(e)
      nil
    end

    def key_and_csr_exist?
      private_key_exists? && csr_exists?
    end

    def certificate_exists?
      ::File.exist?(new_resource.certificate_filename)
    end

    def private_key_exists?
      ::File.exist?(new_resource.private_key_filename)
    end

    def csr_exists?
      ::File.exist?(new_resource.request_filename)
    end
  end
end
