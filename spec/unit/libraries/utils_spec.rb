require 'lib_spec_helper'
require 'helpers'
require 'support/provider_mocks'
load_resources_and_providers

# rubocop:disable Metrics/MethodLength,AbcSize
def setup_dummy_resource(resource_class, options = {})
  let(:resource) do
    resource_class.new('fake_cert').tap do |resource|
      resource.type options[:type]
      resource.bits options[:bits] || 2048
      resource.key_password options[:password]
      resource.country 'US'
      resource.state 'Colorado'
      resource.city 'Denver'
      resource.organization 'RSpec Test Org'
      resource.organizational_unit options[:department]
      resource.common_name options[:common_name] || 'localhost.localdomain'
      if resource.respond_to?(:serial_filename)
        resource.serial_filename '/etc/ssl/CA/serial'
      end
    end
  end
end
# rubocop:enable All

module SSL
  module Utils # rubocop:disable Metrics/ModuleLength
    RSpec.shared_examples_for 'the request_generator' do
      describe '#initialize' do
        it 'initializes with the resource and proper request type' do
          expect(generator.resource).to eq resource
        end
      end

      describe '#private_key' do
        it 'has a private key' do
          expect(generator.private_key).to_not be_nil
        end

        it 'has the right kind of private key' do
          expect(generator.private_key).to be_an EaSSL::Key
        end
      end

      describe '.load' do
        setup_utils_specs
        it 'loads from files' do
          expect { described_class.load(resource) }.to_not raise_error
        end
      end
    end

    RSpec.shared_examples_for 'a non-root certificate' do
      it 'does not generate a self-signed certificate' do
        expect(generator.certificate).to be_nil
      end

      it 'does not generate a certificate authority' do
        expect(generator.ca).to be_nil
      end
    end

    RSpec.describe RequestGenerator do
      let(:generator) { described_class.new(resource) }

      context 'with the ca_certificate resource' do
        context 'when it is a root certificate' do
          setup_dummy_resource(
            Chef::Resource::CaCertificate,
            type: 'root',
            common_name: 'RSpec Test CA',
            password: 'abc123'
          )
          it_behaves_like 'the request_generator'
          it 'does not generate a csr' do
            expect(generator.request).to be_nil
          end

          it 'generates a serial' do
            expect(generator.serial).to_not be_nil
            expect(generator.serial).to be_an EaSSL::Serial
          end

          it 'generates a self-signed certificate' do
            expect(generator.certificate).to_not be_nil
            expect(generator.certificate).to be_an EaSSL::AuthorityCertificate
          end

          it 'creates a certificate authority' do
            expect(generator.ca).to_not be_nil
            expect(generator.ca).to be_an EaSSL::CertificateAuthority
          end
        end

        context 'when it is an intermediate certificate' do
          setup_dummy_resource(
            Chef::Resource::CaCertificate,
            type: 'intermediate',
            common_name: 'RSpec Test CA',
            password: 'abc123'
          )
          it_behaves_like 'the request_generator'
          it_behaves_like 'a non-root certificate'

          it 'generates a csr' do
            expect(generator.request).to_not be_nil
          end

          it 'generates a serial' do
            expect(generator.serial).to_not be_nil
            expect(generator.serial).to be_an EaSSL::Serial
          end
        end
      end

      context 'with the ssl_certificate resource' do
        context 'when it is a server certificate' do
          setup_dummy_resource(
            Chef::Resource::SslCertificate,
            type: 'server'
          )
          it_behaves_like 'the request_generator'
          it_behaves_like 'a non-root certificate'
          it 'generates a csr' do
            expect(generator.request).to_not be_nil
          end

          it 'does not generate a serial' do
            expect(generator.serial).to be_nil
          end
        end

        context 'when it is a client certificate' do
          setup_dummy_resource(
            Chef::Resource::SslCertificate,
            type: 'client'
          )
          it_behaves_like 'the request_generator'
          it_behaves_like 'a non-root certificate'
          it 'generates a csr' do
            expect(generator.request).to_not be_nil
          end

          it 'does not generate a serial' do
            expect(generator.serial).to be_nil
          end
        end
      end
    end
  end
end
