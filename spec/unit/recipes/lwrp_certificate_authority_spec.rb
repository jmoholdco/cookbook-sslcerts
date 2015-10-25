require 'spec_helper'

RSpec.describe 'test::lwrp_certificate_authority' do
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
    end

    it 'creates the key file' do
      expect(chef_run).to create_file('/etc/ssl_test/ca/private/cakey.pem')
    end

    it 'creates the cert file' do
      expect(chef_run).to create_file('/etc/ssl_test/ca/certs/cacert.pem')
    end

    it 'creates the serial file' do
      expect(chef_run).to create_file('/etc/ssl_test/ca/serial')
    end
  end
end
