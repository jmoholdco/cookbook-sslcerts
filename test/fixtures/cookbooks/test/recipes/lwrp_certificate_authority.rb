include_recipe 'chef-vault'

file 'any potential existing certificate' do
  action :delete
  path '/etc/ssl_test/ca/certs/cacert.pem'
end

file 'any potential existing private key' do
  action :delete
  path '/etc/ssl_test/ca/certs/cakey.pem'
end

file 'any potential existing serial file' do
  action :delete
  path '/etc/ssl_test/ca/serial'
end

sslcerts_certificate_authority 'Test CA' do
  action :sync
end
