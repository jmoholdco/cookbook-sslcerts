require 'spec_helper'
require 'openssl'

describe 'test::lwrp_x509' do
  describe command('openssl -rsa -in /etc/ssl_test/mycert.key -check -noout') do
    it 'generates a valid private key' do
      expect(subject.exit_status).to eq 0
    end
  end

  describe command('openssl x509 -in /etc/ssl_test/mycert.crt -noout') do
    it 'generates a valid x509 cert' do
      expect(subject.exit_status).to eq 0
    end
  end

  describe 'The certificate' do
    it 'is verifiable against the key file' do
      crt = OpenSSL::X509::Certificate.new File.read('/etc/ssl_test/mycert.crt')
      key = OpenSSL::PKey::RSA.new File.read('/etc/ssl_test/mycert.key')
      expect(crt.verify(key)).to be_truthy
    end

    it 'is signed with the SHA-256 algorithm' do
      crt = OpenSSL::X509::Certificate.new File.read('/etc/ssl_test/mycert.crt')
      expect(crt.signature_algorithm).to eq 'sha256WithRSAEncryption'
    end
  end
end
