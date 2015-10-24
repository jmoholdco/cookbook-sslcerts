require 'digest/sha2'

include SSLCertsCookbook::Helpers
req_attrs = {
  country: 'US',
  state: 'Colorado',
  organization: 'Default Org',
  department: 'A Department',
  common_name: node['fqdn'],
  email: "root@#{node['fqdn']}"
}

property :name, String, name_property: true
property :ssl_dir, String, required: true

property :type, equal_to: %w(server client), default: 'server'
property :bits, equal_to: [1024, 2048, 4096, 8192], default: 2048
property :days, Fixnum, default: (365 * 5)
property :request_subject, Hash, default: req_attrs
property :key_password, String

property :request_file, String
property :certificate_file, String
property :private_key_file, String
property :cert_id, String, default: Digest::SHA256.new.update(node['fqdn']).to_s

action :create do
  %W(#{ssl_dir} #{ssl_dir}/private #{ssl_dir}/csr #{ssl_dir}/certs).each do |d|
    directory "#{d}" do
      recursive true
    end
  end

  key_content = key.to_pem
  csr_content = csr.to_pem

  cert_id = Digest::SHA256.new.update(node['fqdn']).to_s
  certbag = begin
              data_bag_item('certificates', cert_id)
            rescue => e
              Chef::Log.error('Could not find the certificate in the databag')
              Chef::Log.error("(#{e})")
              nil
            end

  if certbag
    unless ::File.exist?(cert_file)
      file "#{cert_file}" do
        owner 'root'
        group 'root'
        mode '0644'
        sensitive true
        content certbag['certificate']
      end
      node.set['csr_outbox'].delete(node['fqdn'])
    end

  else
    unless ::File.exist?(key_file)
      file "#{key_file}" do
        owner 'root'
        group 'root'
        mode '0400'
        sensitive true
        content key_content
      end
    end

    unless ::File.exist?(csr_file)
      file "#{csr_file}" do
        owner 'root'
        group 'root'
        mode '0644'
        sensitive true
        content csr_content
      end
    end

    unless node['csr_outbox'] && node['csr_outbox'][node['fqdn']]
      node.set['csr_outbox'][node['fqdn']] = {
        id: cert_id,
        csr: csr_content,
        date: Time.now.to_s,
        type: type,
        days: days,
        signed: false
      }
    end
  end
end

protected

def key
  @key ||= resource_key(key_file: key_file, key_pass: key_password, bits: bits)
end

def csr
  @csr ||= resource_csr(key, request_subject)
end

def pkey
  @pkey ||= begin
              ::File.read(::File.expand_path(private_key))
            rescue => e
              Chef::Log.error("Couldn't load the private key #{private_key}")
              Chef::Log.error("(#{e})")
              nil
            end
end

def cert_file
  certificate_file || "#{ssl_dir}/certs/#{node['fqdn']}.pem"
end

def key_file
  private_key_file || "#{ssl_dir}/private/#{node['fqdn']}.pem"
end

def csr_file
  request_file || "#{ssl_dir}/csr/#{node['fqdn']}.csr"
end
