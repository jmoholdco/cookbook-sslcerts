require 'lib_spec_helper'
require './libraries/resource_ca_certificate'
require './libraries/provider_ca_certificate'
require 'support/dummy_node'
require 'support/provider_mocks'

RSpec.shared_examples_for 'the provider' do
  it "returns a #{described_class}" do
    expect(provider).to be_a described_class
  end

  it 'stores the resource passed as new resource' do
    expect(provider.new_resource).to eq resource
  end

  it 'stores the node passed in the run_context' do
    expect(provider.node).to eq node
  end

  context 'when the CA exists on disk' do
    before do
      allow(File).to receive(:exist?).with(
        resource.certificate_filename
      ).and_return true
    end

    describe 'loading the current resource' do
      before(:each) { provider.load_current_resource }

      it 'recognizes that the CA is on disk' do
        expect(File).to have_received(:exist?)
          .with(resource.certificate_filename)
          .at_least(:once)
        expect(provider.on_disk).to be_truthy
      end

      it 'recognizes that the CA is not in the vault' do
        expect(provider.in_vault).to be_falsy
      end
    end

    describe '#action_create' do
      before do
        allow(provider).to receive(:file)
        allow(provider).to receive(:directory)
      end

      before(:each) do
        provider.load_current_resource
        provider.action_create
      end

      it 'does nothing' do
        expect(provider).to_not have_received(:file)
        expect(provider).to_not receive(:file)
        expect(provider).to_not have_received(:directory)
        expect(provider).to_not receive(:directory)
      end
    end
  end

  context 'when the CA does not exist on disk' do
    context 'and does not exist in the vault' do
      before do
        allow(File).to receive(:exist?).with(
          resource.certificate_filename
        ).and_return false
        allow(provider).to receive(:ca_vault_item).and_return nil
      end

      describe 'loading the current resource' do
        before(:each) { provider.load_current_resource }

        it 'recognizes that the CA is not on disk' do
          expect(provider.on_disk).to be_falsy
        end

        it 'recognizes that the CA is not in the vault' do
          expect(provider.in_vault).to be_falsy
        end
      end
      before :each do
        provider.load_current_resource
        provider.action_create
      end
    end
  end
end

RSpec.describe Chef::Provider::CaCertificate do
  before :each do
    allow(File).to receive(:exist?).and_call_original
  end

  %w(debian rhel).each do |platform|
    context "on #{platform}" do
      dummy_node(platform_family: 'platform', fqdn: 'fauxhai.local')
      let(:provider) { described_class.new(resource, run_context) }

      context 'with a root ca' do
        let(:resource) do
          Chef::Resource::CaCertificate.new('fake', run_context).tap do |res|
            res.organization 'RSpec Fake CA Organization'
            res.key_password 'abcd1234'
            res.type 'root'
          end
        end
        it_behaves_like 'the provider'
      end

      context 'with an intermediate ca' do
        before :each do
          provider.load_current_resource
        end
        let(:resource) do
          Chef::Resource::CaCertificate.new('fake', run_context).tap do |res|
            res.organization 'RSpec Fake CA Organization'
            res.key_password 'abcd1234'
            res.type 'intermediate'
          end
        end
        it_behaves_like 'the provider'

        context 'before the certificate has been signed' do
          before { allow(provider).to receive(:do_write_csr).and_call_original }

          it 'writes the certificate' do
            expect(provider).to receive(:do_write_csr)
            provider.action_create
          end
        end

        context 'when the request has been signed' do
          setup_cert_in_certbag
          before do
            allow(node).to receive(:[]).and_call_original
            allow(node).to receive(:attribute?).with('csr_outbox') { true }
            allow(node).to receive(:[]).with('csr_outbox') { dummy_outbox }
            allow(provider).to receive(:do_write_certificate).and_call_original
          end
          before(:each) { provider.action_create }

          it 'recognizes that the certificate has been signed' do
            expect(provider.request_signed?).to be_truthy
          end

          it 'writes the certificate' do
            expect(provider).to have_received(:do_write_certificate)
              .with(loaded_cert.raw_data['certificate'])
          end
        end
      end
    end
  end
end
