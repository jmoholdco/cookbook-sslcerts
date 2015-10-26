require 'lib_spec_helper'
require './libraries/resource_ssl_certificate'
require './libraries/provider_ssl_certificate'

RSpec.describe Chef::Resource::SslCertificate do
  %w(centos debian redhat ubuntu).each do |platform|
    let(:dummy_node) do
      OpenStruct.new.tap do |node|
        node.platform = platform
        node.fqdn = 'fauxhai.local'
        node.platform_family = rhel?(platform) ? 'rhel' : 'debian'
        node.ssl_dir = rhel?(platform) ? '/etc/pki/tls' : '/etc/ssl'
        node.set = node
      end
    end
    context "on #{platform}" do
      before do
        allow_any_instance_of(Chef::Resource::SslCertificate)
          .to receive(:node).and_return(dummy_node)
      end

      let(:resource) { described_class.new('totally_fake') }
      let(:ssl_dir) { dummy_node[:ssl_dir] }
      let(:expected_cert_id) do
        OpenSSL::Digest::SHA256.new.update(
          "#{resource.name}-#{dummy_node.fqdn}"
        ).to_s
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
    end
  end
end
