module SSLCertsCookbook
  module Mixin
    module Resource # rubocop:disable Metrics/ModuleLength
      def cert_id
        Digest::SHA256.new.update(name).to_s
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

    module Provider
      def self.included(base)
        base.send :include, Chef::DSL::Recipe
        base.send :include, Chef::Mixin::ShellOut
        base.send :include, SSLCertsCookbook::Helpers
        base.send :include, Chef::DSL::DataQuery
      end

      def add_request_to_outbox # rubocop:disable Metrics/AbcSize
        node.set['csr_outbox'][new_resource.cert_id] = {
          id: new_resource.cert_id,
          csr: generated_csr.to_pem,
          date: Time.now.to_s,
          type: new_resource.type,
          days: new_resource.days,
          signed: false,
          hostname: node['fqdn']
        }
      end

      def generated_private_key
        @private_key ||= if ::File.exist?(new_resource.private_key_filename)
                           load_rsa_key(
                             new_resource.private_key_filename,
                             new_resource.key_password
                           )
                         else
                           gen_rsa(new_resource.bits, new_resource.key_password)
                         end
      end

      def request_generated?
        node.attribute?('csr_outbox') &&
          node['csr_outbox'][new_resource.cert_id]
      end

      def request_signed?
        request_generated? && load_certbag
      end

      def load_certbag
        data_bag_item('certificates', new_resource.cert_id)
      rescue => e
        Chef::Log.error('Couldnt find the certificate in the data bag.')
        Chef::Log.error("New resource cert_id: #{new_resource.cert_id}")
        Chef::Log.error(e.message)
        Chef::Log.info(e)
        nil
      end
    end
  end
end
