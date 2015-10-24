module SSLCertsCookbook
  module Utils
    class CertificateName
      attr_reader :options, :name

      def initialize(options)
        @options = options
        @name = parse_name(options)
      end

      alias_method :ssl, :name

      private

      def name_crosswalk
        {
          'C' => :country,
          'ST' => :state,
          'L' => :city,
          'O' => :organization,
          'OU' => :department,
          'CN' => :common_name,
          'emailAddress' => :email
        }
      end

      def parse_name(opts)
        tmp = []
        name_crosswalk.each do |k, v|
          tmp << [k, opts[v], OpenSSL::ASN1::PRINTABLESTRING] if opts[v]
        end
        OpenSSL::X509::Name.new(tmp)
      end
    end
  end
end
