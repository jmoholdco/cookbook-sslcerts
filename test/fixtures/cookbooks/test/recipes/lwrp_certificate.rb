include_recipe 'chef-vault'

ssl_directory = value_for_platform_family(
  'debian' => '/etc/ssl',
  'rhel' => '/etc/pki/tls'
)

sslcerts_certificate node['fqdn'] do
  action :create
  ssl_dir ssl_directory
  request_subject(
    country: 'US',
    state: 'Colorado',
    organization: 'Default Org',
    common_name: node['fqdn']
  )
end
