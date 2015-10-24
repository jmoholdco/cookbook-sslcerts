require 'spec_helper'

RSpec.describe 'test::lwrp_rsa_key' do
  describe command('openssl rsa -in /etc/ssl_test/rsakey.pem -check -noout') do
    it 'generates a valid unsecured private key' do
      expect(subject.exit_status).to eq 0
    end
  end

  describe command('echo oink | openssl rsa -in /etc/ssl_test/rsakeypass.pem \
                   -check -noout -passin stdin') do
    it 'generates a valid password-protected private key' do
      expect(subject.exit_status).to eq 0
    end
  end
end
