include SSLCertsCookbook::Helpers

property :name, String, name_property: true
property :ca_path, String, default: node['sslcerts']['ca_dir']
property :cert_vault, String, default: 'cacerts'
property :vault_item, String, default: node['hostname']

property :key_password, String
property :bits, Fixnum, equal_to: [1024, 2048, 4096, 8192], default: 4096
property :days, Fixnum, default: (365 * 10)

property :ca_name, Hash, default: node['sslcerts']['ca_name']

property :ca_cert_file, String
property :ca_private_key_file, String
property :ca_serial_file, String

property :cacert_filename, String
property :cakey_filename, String

property :cacert_content, String
property :cakey_content, String
property :ca_serial_content, String

load_current_value do
  cacert_content IO.read(ca_cert_path) if ::File.exist?(ca_cert_path)
  cakey_content IO.read(ca_key_path) if ::File.exist?(ca_key_path)
  ca_serial_content IO.read(ca_serial_path) if ::File.exist?(ca_serial_path)
end

action :sync do
  %W(#{ca_path} #{ca_path}/certs #{ca_path}/private).each do |dir|
    directory dir do
      recursive true
    end
  end

  vault = ca_vault_item
  if ca_in_vault?
    converge_if_changed :cacert_content do
      file ca_cert_path do
        owner 'root'
        group 'root'
        mode '0644'
        sensitive true
        content vault['certificate']
      end
    end

    converge_if_changed :cakey_content do
      file ca_key_path do
        owner 'root'
        group 'root'
        mode '0400'
        sensitive true
        content vault['private_key']
      end
    end

    converge_if_changed :ca_serial_content do
      file ca_serial_path do
        owner 'root'
        group 'root'
        mode '0644'
        sensitive true
        content vault['serial']
      end
    end
  end
end

protected

def ca_cert_path
  return ca_cert_file if ca_cert_file
  return "#{ca_path}/certs/#{cacert_filename}" if cacert_filename
  "#{ca_path}/certs/cacert.pem"
end

def ca_key_path
  return ca_private_key_file if ca_private_key_file
  return "#{ca_path}/private/#{cakey_filename}" if cakey_filename
  "#{ca_path}/private/cakey.pem"
end

def ca_serial_path
  return ca_serial_file if ca_serial_file
  return "#{ca_path}/serial" if ::File.exist?("#{ca_path}/serial")
  return "#{ca_path}/serial.txt" if ::File.exist?("#{ca_path}/serial.txt")
  "#{ca_path}/serial"
end

def ca_vault_item
  chef_vault_item(cert_vault, vault_item)
end

def ca_in_vault?
  true if ca_vault_item
rescue => e
  Chef::Log.info("Couldn't load the vault item. (#{e})")
  Chef::Log.info("It either doesn't exist or isn't encrypted for this node.")
  return false
end

def ca_exists?
  ::File.exist?(ca_cert_path) && ::File.exist?(ca_key_path) &&
    ::File.directory?(ca_path)
end

def cakey
  resource_key(key_file: ca_key_path, key_pass: key_password, bits: bits)
end

def cacert
  resource_cacert(ca_cert_path,
                  bits: bits,
                  password: key_password,
                  name: ca_name)
end

def read_serial
  File.read(File.expand_path(ca_serial_path))
end
