require 'lib_spec_helper'
require './libraries/resource_ssl_certificate'
require './libraries/provider_ssl_certificate'

def setup_existing_certificate(file_type)
  case file_type
  when :yaml then setup_yaml
  when :file then setup_cert_from_files
  end
end

def setup_yaml
  allow(::File).to receive(:exist?)
    .with("#{provider.csr_cache_path}/#{provider.new_resource.name}")
    .and_return(true)
  allow(YAML).to receive(:load_file).and_return dummy_existing_request
end

def setup_cert_from_files # rubocop:disable Metrics/AbcSize,MethodLength
  allow(::File).to receive(:exist?)
    .with("#{provider.csr_cache_path}/#{provider.new_resource.name}")
    .and_return(false)
  allow(::File).to receive(:exist?)
    .with('/etc/pki/tls/private/totally_fake-fauxhai.local.pem')
    .and_return true
  allow(::File).to receive(:exist?)
    .with('/etc/pki/tls/csr/totally_fake-fauxhai.local.pem')
    .and_return true
  allow(EaSSL::Key).to receive(:load).and_return(true)
  allow(EaSSL::SigningRequest).to receive(:load).and_return(true)
end

RSpec.describe Chef::Provider::SslCertificate do
  let(:dummy_existing_request) do
    OpenStruct.new.tap do |req|
      req.name = EaSSL::CertificateName.new(organization: req.organization)
      req.key = EaSSL::Key.new(bits: 4096, password: nil)
      req.csr = EaSSL::SigningRequest.new(key: req.key, name: req.name)
    end
  end

  let(:resource) do
    Chef::Resource::SslCertificate.new('totally_fake').tap do |res|
      res.organization 'RSpec Test CA'
    end
  end

  before do
    allow(Chef::Config).to receive(:[]).with(:file_cache_path)
      .and_return('/var/chef/cache')
    allow(run_context).to receive(:definitions)
    allow(node).to receive(:[]).with('fqdn').and_return 'fauxhai.local'
    allow(node).to receive(:key?).with(:platform_family).and_return true
    allow(node).to receive(:platform_family).and_return 'rhel'
    allow(node).to receive(:[]).with(:platform_family).and_return 'rhel'
  end

  let(:node) { double('Chef::Node') }
  let(:events) { double('Chef::Events').as_null_object }
  let(:run_context) { double('Chef::RunContext', node: node, events: events) }

  let(:provider) { described_class.new(resource, run_context) }
  let(:ssl_dir) { '/etc/pki/tls' }

  it "returns a #{described_class}" do
    expect(provider).to be_a described_class
  end

  it 'stores the resource passed as new resource' do
    expect(provider.new_resource).to eq resource
  end

  it 'stores the node passed in the run_context' do
    expect(provider.node).to eq node
  end

  describe 'loading the current resource' do
    context 'when running #load_current_resource' do
      context 'when the certificate exists in yaml on the disk' do
        before(:each) { setup_existing_certificate(:yaml) }
        before(:each) { provider.load_current_resource }

        it 'tries to load the file' do
          expect(YAML).to have_received(:load_file)
        end

        it 'sets @existing_request to the loaded file' do
          expect(provider.existing_request).to be_an(OpenStruct)
          expect(provider.existing_request.key).to be_an(EaSSL::Key)
          expect(provider.existing_request.csr).to be_an(EaSSL::SigningRequest)
        end

        it 'has a default ssl dir depending on the platform' do
          expect(provider.current_resource.ssl_dir).to eq ssl_dir
        end

        it 'has a default request filename' do
          expect(provider.current_resource.request_filename)
            .to eq "#{ssl_dir}/csr/totally_fake-fauxhai.local.pem"
        end

        it 'has a default private key filename' do
          expect(provider.current_resource.private_key_filename)
            .to eq "#{ssl_dir}/private/totally_fake-fauxhai.local.pem"
        end

        it 'has a default certificate filename' do
          expect(provider.current_resource.certificate_filename)
            .to eq "#{ssl_dir}/certs/totally_fake-fauxhai.local.pem"
        end
      end

      context 'when the key and csr files exist on the system' do
        before(:each) { setup_existing_certificate(:file) }
        before(:each) { provider.load_current_resource }

        it 'tries to load the files' do
          expect(EaSSL::Key).to have_received(:load)
            .with(provider.current_resource.private_key_filename)
          expect(EaSSL::SigningRequest).to have_received(:load)
            .with(provider.current_resource.request_filename)
        end
      end
    end
  end
end
