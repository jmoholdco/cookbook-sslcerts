require 'eassl'
require 'eassl_overrides'
require 'digest/sha2'
require 'chef/data_bag_item'
require 'support/dummy_certs'

def fake_private_key
  EaSSL::Key.load(File.expand_path('spec/support/pki/key.pem'))
end

def generate_outbox(hostname)
  id = Digest::SHA256.new.update(hostname).to_s
  type = 'server'
  key = fake_private_key
  csr = EaSSL::SigningRequest.new(
    name: _default_name(hostname),
    key: key,
    type: type
  )
  DummyOutbox.new(hostname: hostname, id: id, csr: csr, key: key, type: type)
end

def _default_name(hostname)
  EaSSL::CertificateName.new(
    country: 'US',
    state: 'Colorado',
    city: 'Denver',
    organization: 'RSpec Test Certificate Org',
    common_name: hostname
  )
end

def sign_certificate(outbox)
  ca = load_ca_fixture
  outbox.signed = true
  DummySigned.new(
    outbox: outbox,
    cert: ca.create_certificate(*outbox.signing_args)
  )
end

def load_ca_fixture
  EaSSL::CertificateAuthority.load(
    ca_path: File.expand_path('spec/support/ca'),
    ca_password: 'abc123'
  )
end
