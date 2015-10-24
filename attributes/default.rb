default['sslcerts']['dir'] = value_for_platform_family(
  'rhel' => '/etc/pki/tls',
  'default' => '/etc/ssl'
)

default['sslcerts']['request']['subject'] = {
  org: 'JML Holdings, LLC',
  country: 'US',
  state: 'Colorado',
  common_name: node['fqdn']
}
