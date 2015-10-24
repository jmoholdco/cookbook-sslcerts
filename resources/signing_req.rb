require 'digest/sha2'
include SSLCertsCookbook::Helpers

property :name, String, name_property: true
property :org, String, required: true
property :org_unit, String
property :country, String, required: true
property :state, String
property :city, String
property :common_name, String, default: node['fqdn']
property :email, String, default: nil
property :type, String, equal_to: %w(server client), default: 'server'

cert_dir = node['platform_family'] == 'debian' ? '/etc/ssl' : '/etc/pki/tls'
property :request_file, String, default: "#{cert_dir}/csr/#{node['fqdn']}.csr"
property :cert_path, String, default: "#{cert_dir}/certs/#{node['fqdn']}.pem"
property :key_file, String, default: "#{cert_dir}/private/#{node['fqdn']}.pem"
property :key_pass, String, default: nil
property :bits, equal_to: [1024, 2048, 4096, 8192], default: 2048

property :certificate, String
property :private_key, String
property :request, String
property :signed, [TrueClass, FalseClass]
property :cert_id, String, default: Digest::SHA256.new.update(node['fqdn']).to_s

load_current_value do
  if (certbag = data_bag_item('certificates', cert_id))
    certificate certbag['certificate']
    signed true
  elsif ::File.exist?(cert_path)
    certificate IO.read(cert_path)
  end
  request ::File.read(request_file) if ::File.exist?(request_file)
  private_key ::File.read(key_file) if ::File.exist?(key_file)
end

action :create do
  key_content = key.to_pem
  csr_content = csr.to_pem

  file "#{key_file}" do
    action :create_if_missing
    mode '0400'
    owner 'root'
    group 'root'
    sensitive true
    content key_content
  end

  file "#{request_file}" do
    action :create_if_missing
    mode '0644'
    owner 'root'
    group 'root'
    sensitive true
    content csr_content
  end

  node.set['csr_outbox'][node['fqdn']] = {
    id: cert_id,
    csr: csr_content,
    date: Time.now.to_s,
    type: type
  }
end

protected

def key
  @key ||= resource_key(key_file: key_file, key_pass: key_pass, bits: bits)
end

def csr
  @csr ||= resource_csr(key, subject)
end

def subject
  @subject ||= {
    country: country,
    state: state,
    organization: org,
    department: org_unit,
    common_name: common_name,
    email: email
  }
end
