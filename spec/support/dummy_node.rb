def dummy_node(opts = {})
  _dummy_node_setup(opts)
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
  _expected_filenames
end

def double_dummy_node(opts = {})
  _dummy_node_setup(opts)
  let(:events) { double('Chef::Events').as_null_object }
  let(:run_context) { double('Chef::RunContext', node: node, events: events) }
  _expected_filenames
end

def _dummy_node_setup(opts = {})
  fqdn = opts[:fqdn]
  platform_family = opts[:platform_family]
  let(:node) do
    Chef::Node.new.tap do |n|
      n.automatic_attrs[:os] = 'linux'
      n.automatic_attrs[:platform_family] = platform_family
      n.automatic_attrs[:fqdn] = fqdn
    end
  end
  let(:ssl_dir) { platform_family == 'rhel' ? '/etc/pki/tls' : '/etc/ssl' }
end

def _expected_filenames # rubocop:disable Metrics/AbcSize
  let(:expected_pkey_filename) do
    "#{ssl_dir}/private/#{resource.name}-#{node.fqdn}.pem"
  end

  let(:expected_csr_filename) do
    "#{ssl_dir}/csr/#{resource.name}-#{node.fqdn}.pem"
  end

  let(:expected_cert_filename) do
    "#{ssl_dir}/certs/#{resource.name}-#{node.fqdn}.pem"
  end
end

def expected_directories
  %W(
    /var/chef/cache/csr_outbox
    #{ssl_dir}/private
    #{ssl_dir}/csr
    #{ssl_dir}/certs
  )
end
