require 'spec_helper'

RSpec.describe 'test::lwrp_certificate' do
  if os[:family] == 'redhat'
    describe file('/etc/pki/tls/private/localhost.localdomain.pem') do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      it { is_expected.to be_mode 400 }
    end

    describe file('/etc/pki/tls/csr/localhost.localdomain.csr') do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
    end

    describe x509_private_key('/etc/pki/tls/private/localhost.localdomain.pem') do # rubocop:disable Metrics/LineLength
      it { is_expected.not_to be_encrypted }
      it { is_expected.to be_valid }
    end

  elsif %w(debian ubuntu).include?(os[:family])
    describe file('/etc/ssl/private/localhost.pem') do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      it { is_expected.to be_mode 400 }
    end

    describe file('/etc/ssl/csr/localhost.csr') do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
    end

    describe x509_private_key('/etc/ssl/private/localhost.pem') do
      it { is_expected.not_to be_encrypted }
      it { is_expected.to be_valid }
    end
  end
end
