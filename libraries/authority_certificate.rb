module SSLCertsCookbook
  module Utils
    class AuthorityCertificate
      def initialize(options)
        @options = { key: nil, name: {} }.update(options)
        @cert ||= OpenSSL::X509::Certificate.new
      end
    end
  end
end
