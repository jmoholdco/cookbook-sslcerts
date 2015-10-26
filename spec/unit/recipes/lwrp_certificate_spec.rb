require 'spec_helper'
require 'json'
require 'hashie/mash'

RSpec.shared_examples 'the lwrp' do
  let(:ssldir) do
    case chef_run.node['platform']
    when 'centos'
      '/etc/pki/tls'
    else
      '/etc/ssl'
    end
  end

  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end

  it 'has the right fqdn' do
    expect(chef_run.node['fqdn']).to eq 'localhost.localdomain'
  end

  it 'creates all the directories' do
    expect(chef_run).to create_directory("#{ssldir}")
    expect(chef_run).to create_directory("#{ssldir}/private")
    expect(chef_run).to create_directory("#{ssldir}/certs")
    expect(chef_run).to create_directory("#{ssldir}/csr")
  end
end

RSpec.describe 'test::lwrp_certificate' do
  {
    'centos' => %w(7.0 7.1.1503),
    'debian' => %w(8.0 8.1),
    'ubuntu' => %w(14.04 15.04 15.10)
  }.each do |platform, versions|
    versions.each do |version|
      context "on #{platform} v#{version}" do
        let(:opts) do
          {
            platform: platform,
            version: version,
            step_into: ['ssl_certificate']
          }
        end

        let(:private_key_file) do
          case platform
          when 'centos' then '/etc/pki/tls/private/localhost.localdomain.pem'
          else '/etc/ssl/private/localhost.localdomain.pem'
          end
        end

        let(:csr_file) do
          case platform
          when 'centos' then '/etc/pki/tls/csr/localhost.localdomain.pem'
          else '/etc/ssl/csr/localhost.localdomain.pem'
          end
        end

        let(:certificate_file) do
          case platform
          when 'centos' then '/etc/pki/tls/certs/localhost.localdomain.pem'
          else '/etc/ssl/certs/localhost.localdomain.pem'
          end
        end

        context 'when the request has not yet been generated' do
          let(:chef_run) do
            ChefSpec::SoloRunner.new(opts) do |node|
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
            expect(chef_run).to create_file(private_key_file)
          end

          it 'creates the csr file' do
            expect(chef_run).to create_file(csr_file)
          end

          it 'sets the node attribute `csr_outbox`' do
            expect(chef_run.node['csr_outbox']).to_not be_nil
          end
        end

        context 'when the request has been generated and signed' do
          let(:chef_run) do
            ChefSpec::SoloRunner.new(opts) do |node|
              node.automatic['fqdn'] = 'localhost.localdomain'
              node.set['csr_outbox'] = JSON.parse(
                File.read(File.expand_path('test/fixtures/outbox.json'))
              )
            end.converge(described_recipe)
          end

          before do
            item = JSON.parse(
              File.read(File.expand_path('test/fixtures/signed.json'))
            )
            stub_data_bag_item(
              'certificates',
              '151b43d38accf64fa2ed75d267cce8c75cfc07ae86064c4ca6e33354e2a9d99a'
            ).and_return(Hashie::Mash.new(item))
            allow(File).to receive(:exist?).and_call_original
            allow(File).to receive(:exist?)
              .with('/etc/pki/tls/certs/fauxhai.local.pem')
              .and_return(false)
            allow(File).to receive(:exist?)
              .with('/etc/ssl/certs/fauxhai.local.pem')
              .and_return(false)
          end

          it_behaves_like 'the lwrp'

          it 'creates the certificate file from the databag' do
            expect(chef_run).to create_file(certificate_file)
          end

          it 'removes the request from the outbox' do
            expect(chef_run.node['csr_outbox']).to eq({})
          end
        end
      end
    end
  end
end
