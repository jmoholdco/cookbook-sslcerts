require 'chef/mixin/securable'
require_relative 'mixin_cert_request'

module SSLCertsCookbook
  module Mixin
    module Resource
      include Chef::Mixin::Securable
      include SSLCertsCookbook::Mixin::CertRequest

      def initialize(name, run_context = nil)
        super
        @name = name
        @ssl_dir = _ssl_dir_for_platform
      end

      def cert_id(arg = nil)
        set_or_return(
          :cert_id,
          arg,
          kind_of: String,
          regex: /[a-f0-9]{64}/,
          default: lazy { generate_cert_id }
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

      def ssl_dir(arg = nil)
        set_or_return(
          :ssl_dir,
          arg,
          kind_of: String
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

      def safe_node_attr(attribute_to_get = nil)
        return unless run_context
        run_context.node[attribute_to_get]
      end

      def _ssl_dir_for_platform
        case safe_node_attr('platform_family')
        when 'rhel', 'fedora' then '/etc/pki/tls'
        else '/etc/ssl'
        end
      end
    end
  end
end
