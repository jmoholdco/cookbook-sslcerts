require 'lib_spec_helper'
require './libraries/resource_ca_certificate'
require './libraries/provider_ca_certificate'

RSpec.describe Chef::Resource::CaCertificate do
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
        allow_any_instance_of(Chef::Resource::CaCertificate)
          .to receive(:node).and_return(dummy_node)
      end

      let(:resource) { described_class.new('totally_fake') }
      let(:ssl_dir) { dummy_node[:ssl_dir] + '/CA' }
      let(:expected_cert_id) do
        OpenSSL::Digest::SHA256.new.update(resource.name).to_s
      end

      it_behaves_like 'an sslcerts custom resource'
      it 'has a name' do
        expect(resource.name).to eq 'totally_fake'
      end

      it 'has a default ca name' do
        expect(resource.ca_name).to eq resource.name.gsub(/\s+/, '_').downcase
      end

      it 'has a default common name equal to the resource name' do
        expect(resource.common_name).to eq resource.name
      end

      it 'has a default authority_type of root' do
        expect(resource.authority_type).to eq 'root'
      end

      it 'has type aliased as authority_type' do
        expect(resource.type).to eq 'root'
      end

      it 'defaults to being saved in a vault' do
        expect(resource.save_in_vault).to be_truthy
      end

      it 'only accepts true and false for save_in_vault?' do
        expect { resource.save_in_vault 'a' }.to raise_error(ArgumentError)
        expect { resource.save_in_vault :a }.to raise_error(ArgumentError)
        expect { resource.save_in_vault b: 'a' }.to raise_error(ArgumentError)
        expect { resource.save_in_vault b: :a }.to raise_error(ArgumentError)
        expect { resource.save_in_vault false }.to_not raise_error
      end

      it 'only accepts `root` or `intermediate` as type' do
        expect { resource.type 'a' }.to raise_error(ArgumentError)
        expect { resource.type :a }.to raise_error(ArgumentError)
        expect { resource.type b: :a }.to raise_error(ArgumentError)
        expect { resource.type 'intermediate' }.to_not raise_error
      end

      it 'has methods aliased' do
        expect(resource.ca_cert_path).to eq resource.certificate_filename
        expect(resource.private_key_path).to eq resource.private_key_filename
        expect(resource.ca_serial_path).to eq resource.serial_filename
        expect(resource.ca_csr_path).to eq resource.request_filename
      end
    end
  end
end
