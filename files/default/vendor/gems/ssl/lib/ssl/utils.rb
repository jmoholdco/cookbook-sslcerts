require 'fileutils'
require 'forwardable'
require 'ssl/utils/request_helpers'
require 'ssl/utils/request_generator'
require 'ssl/utils/cert_key_verifier'

module SSL
  module Utils
    class InvalidKeyLengthError < ArgumentError
      def message
        'Key length (bits) must be a power of two greater than or equal to 1024'
      end
    end

    class CertKeyMismatchError < RuntimeError
      def message
        'The Certificate and Private Key do not match!!'
      end
    end
  end
end
