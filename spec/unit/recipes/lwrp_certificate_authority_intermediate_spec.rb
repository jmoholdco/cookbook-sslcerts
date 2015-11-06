require 'spec_helper'

RSpec.describe 'test::lwrp_certificate_authority_intermediate' do
  include ChefVault::TestFixtures.rspec_shared_context(true)
  let(:chef_run) do
    ChefSpec::SoloRunner.new(opts) do |node|
      node.automatic['fqdn'] = 'localhost.localdomain'
      node.automatic['hostname'] = 'localhost'
    end.converge(described_recipe)
  end

  before do
    allow(Chef::DataBagItem).to receive(:load).with(:cacerts, 'TestCA')
  end

  let(:opts) { { step_into: ['ca_certificate'] } }

  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end

  describe 'creating the files' do
    it 'creates the directory structure' do
      expect(chef_run).to create_directory('/etc/ssl_test/ca')
      expect(chef_run).to create_directory('/etc/ssl_test/ca/certs')
      expect(chef_run).to create_directory('/etc/ssl_test/ca/private')
      expect(chef_run).to create_directory('/etc/ssl_test/ca/csr')
    end

    it 'creates the key file' do
      expect(chef_run).to create_file('/etc/ssl_test/ca/private/cakey.pem')
    end

    it 'creates the csr file' do
      expect(chef_run).to create_file('/etc/ssl_test/ca/csr/ca_csr.pem')
    end

    it 'creates the serial file' do
      expect(chef_run).to create_file('/etc/ssl_test/ca/serial')
    end
  end

  describe 'the custom matcher' do
    it 'works with no `with` clause' do
      expect(chef_run).to create_ca_certificate('Test CA')
    end

    it 'works with a `with` clause' do
      expect(chef_run).to create_ca_certificate('Test CA').with(
        ca_path: '/etc/ssl_test/ca',
        key_password: 'abcdefg123456'
      )
    end
  end
end
