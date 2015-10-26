$LOAD_PATH.unshift(
  *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
)

require 'eassl'

module EaSSL
  class Serial
    def export
      format('%04X', @next)
    end

    def save!
      return export unless @path
      File.open(@path, 'w') do |io|
        io.write "#{export}\n"
      end
    end
  end
end

module SSLCertsCookbook
  module Helpers
    def self.included(_base)
      require 'openssl' unless defined?(OpenSSL)
    end

    def key_length_valid?(number)
      number >= 1024 && number & (number - 1) == 0
    end

    def key_file_valid?(key_file_path, key_password = nil)
      return false unless File.exist?(key_file_path)
      key = OpenSSL::PKey::RSA.new File.read(key_file_path), key_password
      key.private?
    end

    def ca_exists?
      return unless defined?(:new_resource)
      File.exist?(new_resource.ca_path)
    end

    def ca_in_vault?
      return unless defined?(:new_resource)
      true if ca_vault_item(new_resource.ca_name)
    end

    def ca_vault_item(ca_name)
      chef_vault_item(:cacerts, ca_name)
    rescue => e
      Chef::Log.error('Error loading the CA from the vault')
      Chef::Log.error("Your parameters were: :cacerts, #{new_resource.ca_name}")
      Chef::Log.info(e)
      nil
    end

    def gen_rsa(bits, password = nil)
      fail InvalidKeyLengthError unless key_length_valid?(bits)
      EaSSL::Key.new(bits: bits, password: password)
    end

    def gen_certname(resource)
      {
        country: resource.country,
        state: resource.state,
        city: resource.city,
        organization: resource.organization,
        department: resource.organizational_unit,
        common_name: resource.common_name
      }
    end

    def encrypt_rsa_key(rsa_key, password)
      rsa_key = rsa_key.is_a?(OpenSSL::PKey::RSA) ? rsa_key : rsa_key.ssl
      fail InvalidKeyTypeError unless rsa_key.is_a?(OpenSSL::PKey::RSA)
      fail InvalidPasswordTypeError unless password.is_a?(String)
      cipher = OpenSSL::Cipher::Cipher.new('des3')
      rsa_key.to_pem(cipher, password)
    end

    def load_rsa_key(key_file, password = nil)
      EaSSL::Key.load(key_file, password)
    end

    def resource_key(options = {})
      if key_file_valid?(options[:key_file], options[:key_pass])
        load_rsa_key(options[:key_file], options[:key_pass])
      else
        gen_rsa(options[:bits], options[:key_pass])
      end
    end

    def generate_self_signed
      return unless defined?(:new_resource)
    end

    def resource_subject(new_resource)
      {
        country: new_resource.country,
        state: new_resource.state,
        city: new_resource.city,
        organization: new_resource.org,
        department: new_resource.org_unit,
        common_name: new_resource.common_name,
        email: new_resource.email
      }
    end

    def resource_csr(key, subject)
      EaSSL::SigningRequest.new(key: key,
                                name: EaSSL::CertificateName.new(subject))
    end

    def resource_cacert(ca_cert_path, options = {})
      if ::File.exist?(ca_cert_path)
        EaSSL::AuthorityCertificate.load(File.expand_path(ca_cert_path))
      else
        EaSSL::AuthorityCertificate.new(
          key: gen_rsa(options[:bits], options[:password]),
          name: options[:name]
        )
      end
    end

    def key_cert_match?(private_key, certificate)
      key = OpenSSL::PKey::RSA.new private_key
      cert = OpenSSL::X509::Certificate.new certificate
      key.public_key.to_pem == cert.public_key.to_pem
    end

    def ca_vault_cert_match?(vault_item, options = {})
      vault_key_content = vault_item['private_key']
      vault_crt_content = vault_item['certificate']
      vault_key_content == options[:key] && vault_crt_content == options[:cert]
    end
  end

  class InvalidKeyLengthError < ArgumentError
    def message
      'Key length (bits) must be a power of two greater than or equal to 1024'
    end
  end

  class InvalidKeyTypeError < TypeError
    def message
      'rsa_key must be a Ruby OpenSSL::PKey::RSA object'
    end
  end

  class InvalidPasswordTypeError < TypeError
    def message
      'RSA key password must be a string'
    end
  end
end
