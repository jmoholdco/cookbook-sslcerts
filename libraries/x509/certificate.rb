# module SSLCertsCookbook
#   module X509
#     class Certificate
#       include SSLCertsCookbook::X509::Helpers

#       attr_reader :cert, :key, :ef

#       def initialize(opts = {})
#         @cert = OpenSSL::X509::Certificate.new
#         @key = validate_key(opts)
#         @ef = OpenSSL::X509::ExtensionFactory.new
#         @subject = parse_subject(opts[:subject])
#       end

#       def gen_cert(expiration)
#         cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
#         cert.not_before = Time.now
#         cert.not_after = Time.now + expiration.to_i * 24 * 60 * 60
#       end

#       private

#       def validate_key(opts = {})
#         if key_file_valid?(opts[:key], opts[:pass])
#           OpenSSL::PKey::RSA.new File.read(opts[:file]), opts[:pass]
#         else
#           OpenSSL::PKey::RSA.new(opts[:bits])
#         end
#       end

#       def parse_subject(subject)
#         '/C=' + subject[:country] +
#           '/O=' + subject[:org] +
#           '/OU=' + subject[:org_unit] +
#           '/CN=' + subject[:common_name]
#       end

#       def extensions
#         [
#           ef.create_extension('basicConstraints', 'CA:TRUE', true),
#           ef.create_extension('subjectKeyIdentifier', 'hash'),
#           ef.create_extension('')
#         ]
#       end
#     end
#   end
# end
