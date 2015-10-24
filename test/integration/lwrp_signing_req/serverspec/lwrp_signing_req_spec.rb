require 'spec_helper'
require 'openssl'

RSpec.describe 'test::lwrp_signing_req' do
  describe file('/etc/ssl_test/myreq.key') do
    it { is_expected.to exist }
  end

  describe file('/etc/ssl_test/myreq.csr') do
    it { is_expected.to exist }
  end

  describe command('openssl -rsa -in /etc/ssl_test/mycsr.key -check -noout') do
    it 'generates a valid private key' do
      expect(subject.exit_status).to eq 0
    end
  end
end
