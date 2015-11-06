module SSL
  module Utils
    module RequestHelpers
      def gen_rsa(bits, password = nil)
        fail InvalidKeyLengthError unless key_length_valid?(bits)
        EaSSL::Key.new(bits: bits, password: password)
      end

      def key_length_valid?(number)
        number >= 1024 && number & (number - 1) == 0
      end

      def generate_certificate_request(request_type)
        return generate_self_signed if request_type == 'root'
        request_type = 'subordinate' if request_type == 'intermediate'
        @request = EaSSL::SigningRequest.new(
          key: @private_key,
          name: @name,
          type: request_type,
          subject_alt_name: resource.subject_alt_names
        )
      end

      def generate_self_signed
        @certificate = EaSSL::AuthorityCertificate.new(
          key: @private_key,
          name: @name
        )

        @ca = EaSSL::CertificateAuthority.new(
          key: @private_key,
          certificate: @certificate,
          serial: @serial
        )
      end
    end
  end
end
