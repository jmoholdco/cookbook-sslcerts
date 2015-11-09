default['sslcerts']['dir'] = value_for_platform_family(
  'rhel' => '/etc/pki/tls',
  'default' => '/etc/ssl'
)

default['sslcerts']['request']['subject'] = {
  org: 'JML Holdings, LLC',
  country: 'US',
  city: 'Denver',
  state: 'Colorado',
  subject_alt_names: [node['hostname']],
  common_name: node['fqdn']
}
