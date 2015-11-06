require 'lib_spec_helper'
require './libraries/resource_ssl_certificate'
require './libraries/provider_ssl_certificate'
require 'support/dummy_node'

RSpec.describe Chef::Resource::SslCertificate do
  %w(rhel debian).each do |platform|
    context "on #{platform}" do
      dummy_node(os: 'linux', platform_family: platform, fqdn: 'fauxhai.local')
      let(:resource) { described_class.new('totally_fake', run_context) }
      let(:expected_cert_id) do
        OpenSSL::Digest::SHA256.new.update("#{resource.name}-#{node.fqdn}").to_s
      end

      it_behaves_like 'an sslcerts custom resource'

      it 'has a name' do
        expect(resource.name).to eq 'totally_fake'
      end

      it 'has a default action of create' do
        expect(resource.action).to eq :create
      end

      it 'has a default certificate type of server' do
        expect(resource.type).to eq 'server'
      end

      it 'has a default key length (bits) of 2048' do
        expect(resource.bits).to eq 2048
      end

      it 'has a default days (valid) of 5 years' do
        expect(resource.days).to eq(365 * 5)
      end

      it 'has a #default_common_name of the node fqdn' do
        expect(resource.default_common_name).to eq 'fauxhai.local'
      end

      it 'has a default #common_name that matches #default_common_name' do
        expect(resource.common_name).to eq resource.default_common_name
      end

      it 'has a default #private_key_filename' do
        expect(resource.private_key_filename).to eq expected_pkey_filename
      end

      it 'has a default #request_filename' do
        expect(resource.request_filename).to eq expected_csr_filename
      end

      it 'has a default #certificate_filename' do
        expect(resource.certificate_filename).to eq expected_cert_filename
      end
    end
  end
end
