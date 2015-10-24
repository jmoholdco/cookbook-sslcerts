require_relative 'delegation'

module SSLCertsCookbook
  module Utils
    class Certificate
      attr_reader :ssl
      include Delegation
      def initialize(options)
        @options = default_options.update(options)
        @ssl = generate_cert(@options)
        @ef = load_extension_factory(@options)
        add_extensions(@options)
      end

      def_delegator :@ssl, :to_pem

      def sign(ca_key)
        ssl.sign(signing_key(ca_key), OpenSSL::Digest::SHA256.new)
      end

      def sha256_fingerprint
        Digest::SHA256.hexdigest(ssl.to_der).upcase.gsub(/(..)/, '\1:').chop
      end

      private

      def default_options
        {
          days_valid: (365 * 5),
          csr: nil,
          ca_cert: nil,
          comment: 'Ruby/OpenSSL Generated Certificate',
          type: 'server'
        }
      end

      def generate_cert(options)
        OpenSSL::X509::Certificate.new.tap do |crt|
          cert_timestamps(crt, options[:days_valid])
          cert_subject_and_issuer(crt, options)
          crt.public_key = options[:csr].public_key
          crt.serial = options[:serial] || 2
          crt.version = 2
        end
      end

      def load_extension_factory(options)
        OpenSSL::X509::ExtensionFactory.new.tap do |ef|
          ef.subject_certificate = @ssl
          ef.issuer_certificate = issuer(options[:ca_cert], @ssl)
        end
      end

      def signing_key(key_obj)
        key_obj.is_a?(OpenSSL::PKey::RSA) ? key_obj : key_obj.private_key
      end

      def cert_timestamps(crt, days)
        crt.not_before = Time.now
        crt.not_after = not_after(days)
      end

      def cert_subject_and_issuer(crt, options)
        crt.subject = options[:csr].subject
        crt.issuer = issuer(options[:ca_cert], crt.subject)
      end

      def not_after(days_valid)
        Time.now + days_valid * 24 * 60 * 60
      end

      def issuer(ca_cert, default)
        ca_cert ? ca_cert.subject : default
      end

      def generic_extensions
        [
          @ef.create_extension('basicConstraints', 'CA:FALSE'),
          @ef.create_extension('subjectKeyIdentifier', 'hash'),
          @ef.create_extension('nsComment', @options[:comment])
        ]
      end

      def add_ext(*ext)
        @ssl.add_extension(@ef.create_extension(ext))
      end

      def add_extensions(options)
        @ssl.extensions = generic_extensions
        add_ext('authorityKeyIdentifier', 'keyid:always,issuer:always')
        add_server_extensions if options[:type] == 'server'
        add_client_extensions if options[:type] == 'client'
      end

      def add_server_extensions
        add_ext('keyUsage', 'digitalSignature,keyEncipherment')
        add_ext('extendedKeyUsage', 'serverAuth')
      end

      def add_client_extensions
        add_ext('keyUsage', 'nonRepudiation,digitalSignature,keyEncipherment')
        add_ext('extendedKeyUsage', 'clientAuth,emailProtection')
      end
    end
  end
end
