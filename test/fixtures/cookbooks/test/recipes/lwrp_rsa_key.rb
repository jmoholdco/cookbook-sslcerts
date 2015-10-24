file 'any potential existing unsecured key' do
  path '/etc/ssl_test/rsakey.pem'
  action :delete
end

file 'any potential existing passworded key' do
  path '/etc/ssl_test/rsakeypass.pem'
  action :delete
end

# Create directory if not already present
directory '/etc/ssl_test' do
  recursive true
end

# Generate new key
sslcerts_rsa_key '/etc/ssl_test/rsakey.pem' do
  bits 1024
  action :create
end

# Generate new key with password
sslcerts_rsa_key '/etc/ssl_test/rsakeypass.pem' do
  bits 1024
  key_pass 'oink'
  action :create
end
