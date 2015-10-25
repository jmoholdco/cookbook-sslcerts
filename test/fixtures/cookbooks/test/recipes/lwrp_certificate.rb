include_recipe 'sslcerts'

ssl_certificate node['fqdn'] do
  action :create
  organization 'TestingOrg'
  country 'US'
  state 'Colorado'
  city 'Denver'
end
