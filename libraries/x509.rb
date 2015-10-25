require 'openssl'

module SSLCertsCookbook
  module X509
    class IntermediateAuthorityCertificate# {{{
      def initialize(options)
        @options = {
          key: nil,
          name: {}
        }.update(options)
      end

      def name_options
        { common_name: 'CA' }.update(@options[:name])
      end

      def ssl
      end

      def certificate
        @certificate ||= OpenSSL::X509::Certificate.new.tap do |cert|
          cert.not_before = Time.now
          cert.subject = cert.issuer = CertificateName.new(name_options).name
          cert.not_after = options[:days] || five_years_after(cert.not_before)
          cert.public_key = @options[:key].public_key
          cert.version = 2
          cert.serial = Serial.new
        end
      end

      def five_years_after(start_date)
        start_date + ((365 * 5) * 24 * 60 * 60)
      end
    end# }}}

    class CertificateAuthority
      def initialize(opts = {})
        @key, @cert, @serial = opts[:key], opts[:cert], opts[:serial]
      end
    end
  end
end
