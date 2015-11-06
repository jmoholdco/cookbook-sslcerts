module SSLCertsCookbook
  module Mixin
    module CertRequest
      module Provider
        def load_current_resource_request
          do_current_resource_request
          do_current_resource_locale
          current_resource.common_name new_resource.common_name
        end

        private

        def do_current_resource_pem_content
          return unless private_key_exists?
          current_resource.private_key_pem =
            EaSSL::Key.load(new_resource.private_key_filename)
        end

        def do_current_resource_request
          current_resource.organization new_resource.organization
          current_resource.organizational_unit new_resource.organizational_unit
          current_resource.subject_alt_names new_resource.subject_alt_names
        end

        def do_current_resource_locale
          current_resource.country new_resource.country
          current_resource.city new_resource.city
          current_resource.state new_resource.state
        end
      end

      def self.included(base)
        base.class_eval do
          alias_method :province, :state
          attr_accessor :request_generator, :private_key_pem
        end
      end

      def initialize(name, run_context = nil)
        super
        @common_name = default_common_name
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
          kind_of: String
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
