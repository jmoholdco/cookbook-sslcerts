include_recipe 'sslcerts'

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

ca_certificate 'Test CA' do
  action :create
  ca_path '/etc/ssl_test/ca'
  key_password 'abcdefg123456'
  ca_name 'TestCA'
  organization 'TestingOrg'
  organizational_unit 'CertificateAuthority'
  city 'Denver'
  state 'Colorado'
  common_name node['fqdn']
  authority_type 'intermediate'
end
