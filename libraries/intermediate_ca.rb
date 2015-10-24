module SSLCertsCookbook
  module Utils
    class IntermediateCA
      def initialize(options = {})
        return load_from_file(options) if options[:key]
        start_fresh(options)
      end

      def load_from_file(options = {})
        key_text = File.read(options[:key]) if pem_exists?(options[:key])
        cert_text = File.read(options[:cert]) if pem_exists?(options[:cert])
        return unless key_text && cert_text
        @key = OpenSSL::PKey::RSA.new key_text, options[:password]
        @cert = OpenSSL::X509::Certificate.new cert_text
        @serial = options[:serial]
      end

      def start_fresh(options)
        options[:name] ||= {}
        @key ||= OpenSSL::PKey::RSA.new options[:bits]
        @cert ||= AuthorityCertificate.new(key: @key, name: options[:name])
        @serial ||= Serial.new(next: 1)
      end

      def self.load(options)
        key = Key.load(options[:key_path], options[:password])
        cert = AuthorityCertificate.load(options[:ca_cert_path])
        serial = Serial.load(options[:serial_path])
        new(key: key, certificate: cert, serial: serial)
      end

      def create_certificate(csr, type = 'server', days_valid = nil)
        opts = { csr: csr, ca_cert: @cert, serial: @serial.issue, type: type }
        opts[:days_valid] = days_valid if days_valid
        crt = Certificate.new(opts)
        @serial.save!
        crt.sign(@key)
        crt
      end

      private

      def pem_exists?(pem_path = nil)
        pem_path && File.exist?(pem_path)
      end
    end
  end
end
