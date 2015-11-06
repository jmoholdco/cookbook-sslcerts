module SSL
  module Utils
    class CertKeyVerifier
      def initialize(certificate, key)
        case certificate
        when String
          @certificate = EaSSL::Certificate.new({}).load(certificate)
        else
          @certificate = certificate
        end
        @key = key
      end

      def verify
        return true unless @key
        @certificate.public_key.to_pem == @key.public_key.to_pem
      end

      def verify!
        return true if verify
        fail CertKeyMismatchError
      end
    end
  end
end
