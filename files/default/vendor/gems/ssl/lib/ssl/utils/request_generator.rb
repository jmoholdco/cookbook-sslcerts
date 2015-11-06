module SSL
  module Utils
    class RequestGenerator
      include RequestHelpers
      extend Forwardable
      attr_reader :resource,
                  :request_type,
                  :name,
                  :private_key,
                  :request,
                  :serial,
                  :certificate,
                  :ca

      def initialize(resource, options = {})
        @resource = resource
        @request_type = options[:type] || resource.type
        @name = EaSSL::CertificateName.new(certname)
        do_generation unless options[:loaded_from_file]
        load_from_files if options[:loaded_from_file]
      end

      def self.load(resource, options = {})
        new(
          resource,
          loaded_from_file: true,
          private_key: options[:key],
          csr: options[:csr],
          serial: options[:serial]
        )
      end

      def private_key_pem
        return private_key.to_pem if resource.key_password
        private_key.ssl.to_pem
      end

      def request_pem
        request.to_pem
      end

      def certificate_pem
        return unless certificate
        certificate.to_pem
      end

      private

      def do_generation
        @private_key = gen_rsa(resource.bits, resource.key_password)
        generate_certificate_request(request_type)
        @serial = generate_serial if %w(root intermediate).include? request_type
      end

      def load_from_files
        @private_key = EaSSL::Key.load(
          resource.private_key_filename,
          resource.key_password
        )
        @request = EaSSL::SigningRequest.load(
          resource.request_filename
        )
        return unless resource.respond_to?(:serial_filename)
        @serial = EaSSL::Serial.load(resource.serial_filename)
      end

      def certname
        {
          country: resource.country,
          state: resource.state,
          city: resource.city,
          organization: resource.organization,
          department: resource.organizational_unit,
          common_name: resource.common_name
        }
      end

      def generate_serial
        EaSSL::Serial.new(next: 1, path: resource.serial_filename)
      end
    end
  end
end
