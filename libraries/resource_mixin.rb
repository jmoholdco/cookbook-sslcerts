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

      def owner(arg = nil)
        set_or_return(
          :owner,
          arg,
          kind_of: String,
          default: 'root'
        )
      end

      def group(arg = nil)
        set_or_return(
          :owner,
          arg,
          kind_of: [String, NilClass],
          default: nil
        )
      end
    end
  end
end
