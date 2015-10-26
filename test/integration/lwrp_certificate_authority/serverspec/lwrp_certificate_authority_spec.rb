require 'spec_helper'

RSpec.describe 'test::lwrp_certificate_authority' do
  ca_dir = '/etc/ssl_test/ca'

  describe file(ca_dir) do
    it { is_expected.to exist }
    it { is_expected.to be_directory }
  end

  describe file("#{ca_dir}/private/cakey.pem") do
    it { is_expected.to exist }
    it { is_expected.to be_file }
    it { is_expected.to be_mode 400 }
  end

  describe file("#{ca_dir}/certs/cacert.pem") do
    it { is_expected.to exist }
    it { is_expected.to be_file }
    it { is_expected.to be_mode 644 }
  end

  describe file("#{ca_dir}/serial") do
    it { is_expected.to be_file }
    it { is_expected.to exist }
  end

  describe x509_private_key("#{ca_dir}/private/cakey.pem") do
    it { is_expected.to be_encrypted }
    it { is_expected.to be_valid }
  end

  describe x509_certificate("#{ca_dir}/certs/cacert.pem") do
    it { is_expected.to be_certificate }
    it { is_expected.to be_valid }
    its(:subject) { is_expected.to match(%r{/C=US/O=TestingOrg}) }
    its(:issuer) { is_expected.to match(%r{/C=US/O=TestingOrg}) }
    its(:keylength) { is_expected.to eq 4096 }
  end
end
