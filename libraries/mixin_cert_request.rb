module SSLCertsCookbook
  module Mixin
    module CertRequest
      def self.included(base)
        base.class_eval do
          alias_method :province, :state
        end
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
    end
  end
end
