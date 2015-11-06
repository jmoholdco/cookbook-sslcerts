require 'json'
require_relative 'outbox_macros'

def setup_existing_certificate(file_type)
  case file_type
  when :file then setup_cert_from_files
  end
end

def setup_dummy_outbox(hostname = 'fauxhai.local')
  let(:dummy_outbox_object) { generate_outbox(hostname, resource) }
  let(:dummy_outbox) { dummy_outbox_object.to_h }
end

def setup_outbox(hostname = 'fauxhai.local')
  setup_dummy_outbox(hostname)
  before do
    node.set['csr_outbox'] = dummy_outbox
  end
end

def setup_nonexisting_cert
  before do
    allow(Chef::DataBagItem).to receive(:load).with(
      'certificates',
      resource.cert_id
    ).and_raise(RuntimeError)
  end
end

def setup_signed_cert
  setup_outbox
  let(:dummy_loaded_key) { dummy_outbox_object.key.private_key.to_pem }
  let(:dummy_loaded_request) { dummy_outbox_object.csr.to_pem }
  let(:loaded_cert) { sign_certificate(dummy_outbox_object).data_bag_item }
end

def setup_cert_from_files # rubocop:disable Metrics/AbcSize
  allow(::File).to receive(:exist?)
    .with("#{provider.csr_cache_path}/#{provider.new_resource.name}")
    .and_return(false)
  allow(::File).to receive(:exist?).with(expected_pkey_filename).and_return true
  allow(::File).to receive(:exist?).with(expected_csr_filename).and_return true
  allow(EaSSL::Key).to receive(:load).and_return(true)
  allow(EaSSL::SigningRequest).to receive(:load).and_return(true)
end

def setup_cert_in_certbag # rubocop:disable Metrics/AbcSize
  setup_signed_cert
  setup_existing_files
  setup_mock_file_reads
  before do
    allow(Chef::DataBagItem).to receive(:load).and_call_original
    allow(Chef::DataBagItem).to receive(:load)
      .with('certificates', resource.cert_id)
      .and_return(loaded_cert)
  end
end

def setup_utils_specs
  setup_dummy_outbox
  let(:dummy_loaded_key) { dummy_outbox_object.key.private_key.to_pem }
  let(:dummy_loaded_request) { dummy_outbox_object.csr.to_pem }
  setup_existing_files
  setup_mock_file_reads
end

def setup_existing_files # rubocop:disable Metrics/AbcSize
  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(resource.private_key_filename) { true }
    allow(File).to receive(:exist?).with(resource.request_filename) { true }
    allow(File).to receive(:exist?)
      .with(resource.certificate_filename) { false }
  end
end

def setup_mock_file_reads # rubocop:disable Metrics/AbcSize,MethodLength
  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(resource.private_key_filename)
      .and_return(dummy_loaded_key)
    allow(File).to receive(:read).with(resource.request_filename)
      .and_return(dummy_loaded_request)
    if resource.respond_to?(:serial_filename)
      allow(File).to receive(:read).with(resource.serial_filename)
        .and_return(dummy_loaded_serial)
    end
  end
end

def dummy_loaded_serial
  File.read(File.expand_path('spec/support/ca/serial.txt'))
end

def loaded_cert_fixture
  JSON.parse(File.read(File.expand_path('spec/support/signed.json')))
end

def dummy_file_resource
  let(:dummy_file) { instance_double(Chef::Resource::File) }
end

def dummy_dir_resource
  let(:dummy_dir) { instance_double(Chef::Resource::Directory) }
end

def mock_chef_resources!
  before do
    allow(provider).to receive(:file).and_call_original
    allow(provider).to receive(:directory).and_call_original
  end
end
