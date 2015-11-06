require 'lib_spec_helper'
require './libraries/resource_ca_certificate'
require './libraries/provider_ca_certificate'
require 'support/dummy_node'

RSpec.describe Chef::Resource::CaCertificate do
  %w(rhel debian).each do |platform|
    context "on #{platform}" do
      dummy_node(platform_family: platform, fqdn: 'fauxhai.local')

      let(:resource) { described_class.new('totally_fake', run_context) }
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
