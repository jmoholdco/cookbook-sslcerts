require 'lib_spec_helper'
require './libraries/resource_ssl_certificate'
require './libraries/provider_ssl_certificate'
require 'support/dummy_node'
require 'support/provider_mocks'

RSpec.describe Chef::Provider::SslCertificate do
  %w(debian rhel).each do |platform|
    context "on #{platform}" do
      dummy_node(os: 'linux', platform_family: platform, fqdn: 'fauxhai.local')

      let(:resource) do
        Chef::Resource::SslCertificate.new(
          'totally_fake',
          run_context
        ).tap do |res|
          res.organization 'RSpec Test CA'
        end
      end

      before do
        allow(Chef::Config).to receive(:[]).and_call_original
        allow(Chef::Config).to receive(:[]).with(:file_cache_path)
          .and_return('/var/chef/cache')
      end

      let(:provider) { described_class.new(resource, run_context) }

      it "returns a #{described_class}" do
        expect(provider).to be_a described_class
      end

      it 'stores the resource passed as new resource' do
        expect(provider.new_resource).to eq resource
      end

      it 'stores the node passed in the run_context' do
        expect(provider.node).to eq node
      end

      it 'doesnt have a default password' do
        expect(provider.new_resource.key_password).to be_nil
        expect(resource.key_password).to be_nil
      end

      describe 'loading the current resource' do
        context 'when running #load_current_resource' do
          context 'when the certificate has not yet been signed' do
            before(:each) { provider.load_current_resource }
            before do
              allow(Chef::DataBagItem).to receive(:load)
                .with('certificates', resource.cert_id).and_raise(RuntimeError)
              allow(provider).to receive(:do_write_csr).and_call_original
            end

            it 'writes the certificate' do
              provider.action_create
              expect(provider).to have_received(:do_write_csr)
            end
          end
        end
      end

      describe '#action_create' do
        shared_examples 'create action' do
          it 'first creates the directory structure' do
            expected_directories.each do |dir|
              expect(provider).to have_received(:directory).with(dir)
            end
          end
        end

        context 'when the request has not yet been generated' do
          setup_nonexisting_cert
          mock_chef_resources!

          before :each do
            provider.load_current_resource
            provider.action_create
          end

          it_behaves_like 'create action'

          it 'recognizes that the request has not yet been generated' do
            expect(provider.csr_exists?).to be_falsy
            expect(provider.certificate_exists?).to be_falsy
            expect(provider.private_key_exists?).to be_falsy
          end

          it 'then creates the files' do
            expect(provider).to have_received(:file)
              .with(resource.private_key_filename)
            expect(provider).to have_received(:file)
              .with(resource.request_filename)
          end
        end

        context 'when the request has been generated' do
          setup_cert_in_certbag
          mock_chef_resources!
          before(:each) do
            provider.load_current_resource
            provider.action_create
          end

          it_behaves_like 'create action'

          describe 'recognizing existing files' do
            it 'csr_exists? is true' do
              expect(provider.csr_exists?).to be_truthy
            end

            it 'private key is expected to exist' do
              expect(provider.private_key_exists?).to be_truthy
            end

            it 'certificate is expected to not exist' do
              expect(provider.certificate_exists?).to be_falsy
            end
          end

          it 'creates the signed certificate' do
            expect(provider).to have_received(:file)
              .with(resource.certificate_filename)
          end
        end
      end
    end
  end
end
