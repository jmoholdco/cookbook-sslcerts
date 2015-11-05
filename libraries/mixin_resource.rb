require 'chef/mixin/securable'
require_relative 'mixin_cert_request'

module SSLCertsCookbook
  module Mixin
    module Resource
      include Chef::Mixin::Securable
      include SSLCertsCookbook::Mixin::CertRequest
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
  end
end
