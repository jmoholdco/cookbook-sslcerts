require 'forwardable'

module EaSSL
  class Key
    extend Forwardable
    attr_reader :ssl
    def initialize(options = {})
      @options = { bits: 2048 }.update(options)
      @ssl ||= OpenSSL::PKey::RSA.new(@options[:bits])
    end

    alias_method :private_key, :ssl
    def_delegator :@ssl, :public_key

    def length
      ssl.n.num_bytes * 8
    end

    def to_pem
      if @options[:password]
        ssl.export(OpenSSL::Cipher::DES.new('EDE3-CBC'), @options[:password])
      else
        ssl.export
      end
    end

    def self.load(pem_file_path, password = nil)
      new.load(File.read(pem_file_path), password)
    end

    def load(pem_string, pass = nil)
      @ssl = OpenSSL::PKey::RSA.new(pem_string, pass || @options[:password])
    rescue => e
      raise "Keyloader Error: Error Decrypting Key. (#{e})"
    end
  end
end
