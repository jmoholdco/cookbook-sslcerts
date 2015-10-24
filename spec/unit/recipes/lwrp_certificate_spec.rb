require 'spec_helper'
require 'json'
require 'hashie/mash'

RSpec.shared_examples 'the lwrp' do
  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end

  it 'has the right fqdn' do
    expect(chef_run.node['fqdn']).to eq 'localhost.localdomain'
  end

  it 'creates all the directories' do
    expect(chef_run).to create_directory('/etc/ssl')
    expect(chef_run).to create_directory('/etc/ssl/private')
    expect(chef_run).to create_directory('/etc/ssl/certs')
    expect(chef_run).to create_directory('/etc/ssl/csr')
  end
end

RSpec.describe 'test::lwrp_certificate', :vault do
  context 'when the request has not yet been generated' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['sslcerts_certificate']) do |node|
        node.automatic['fqdn'] = 'localhost.localdomain'
      end.converge(described_recipe)
    end
    before do
      stub_data_bag_item(
        'certificates',
        '151b43d38accf64fa2ed75d267cce8c75cfc07ae86064c4ca6e33354e2a9d99a'
      ).and_return(nil)
    end
    it_behaves_like 'the lwrp'

    it 'creates the key file' do
      expect(chef_run).to create_file(
        '/etc/ssl/private/localhost.localdomain.pem')
    end

    it 'creates the csr file' do
      expect(chef_run).to create_file(
        '/etc/ssl/csr/localhost.localdomain.csr')
    end

    it 'sets the node attribute `csr_outbox`' do
      expect(chef_run.node['csr_outbox']).to_not be_nil
    end
  end

  context 'when the request has been generated and signed' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['sslcerts_certificate']) do |node|
        node.automatic['fqdn'] = 'localhost.localdomain'
        node.set['csr_outbox'] =
          JSON.parse(File.read(File.expand_path('test/fixtures/outbox.json')))
      end.converge(described_recipe)
    end

    before do
      item = JSON.parse File.read(File.expand_path('test/fixtures/signed.json'))
      stub_data_bag_item(
        'certificates',
        '151b43d38accf64fa2ed75d267cce8c75cfc07ae86064c4ca6e33354e2a9d99a'
      ).and_return(Hashie::Mash.new(item))
    end

    it_behaves_like 'the lwrp'

    it 'creates the certificate file from the databag' do
      expect(chef_run).to create_file(
        '/etc/ssl/certs/localhost.localdomain.pem')
    end

    it 'removes the request from the outbox' do
      expect(chef_run.node['csr_outbox']).to eq({})
    end
  end
end
