RSpec.shared_examples 'an sslcerts custom resource' do
  it 'has a default country of US' do
    expect(resource.country).to eq 'US'
  end

  it 'only accepts a string for a password' do
    expect { resource.key_password 78 }.to raise_error(ArgumentError)
    expect { resource.key_password :hello }.to raise_error(ArgumentError)
    expect { resource.key_password hello: :you }.to raise_error(ArgumentError)
    expect { resource.key_password 'sekrit' }.to_not raise_error
  end

  it 'only accepts a string for organization' do
    expect { resource.organization 78 }.to raise_error(ArgumentError)
    expect { resource.organization :hello }.to raise_error(ArgumentError)
    expect { resource.organization hello: :you }.to raise_error(ArgumentError)
    expect { resource.organization 'sekrit' }.to_not raise_error
  end

  it 'only accepts a string for organizational_unit' do
    expect { resource.organizational_unit 78 }.to raise_error(ArgumentError)
    expect { resource.organizational_unit :hello }.to raise_error(ArgumentError)
    expect { resource.organizational_unit h: :y }.to raise_error(ArgumentError)
    expect { resource.organizational_unit 'sekrit' }.to_not raise_error
  end

  it 'only accepts a two-character string for country' do
    expect { resource.country 'USA' }.to raise_error(ArgumentError)
    expect { resource.country 37 }.to raise_error(ArgumentError)
    expect { resource.country '37' }.to raise_error(ArgumentError)
    expect { resource.country :hello }.to raise_error(ArgumentError)
    expect { resource.country :us }.to raise_error(ArgumentError)
    expect { resource.country 'CA' }.to_not raise_error
  end

  it 'only accepts a string for city' do
    expect { resource.city 78 }.to raise_error(ArgumentError)
    expect { resource.city :hello }.to raise_error(ArgumentError)
    expect { resource.city h: :y }.to raise_error(ArgumentError)
    expect { resource.city 'Denver' }.to_not raise_error
  end

  it 'only accepts a string for state' do
    expect { resource.state 78 }.to raise_error(ArgumentError)
    expect { resource.state :hello }.to raise_error(ArgumentError)
    expect { resource.state h: :y }.to raise_error(ArgumentError)
    expect { resource.state 'Colorado' }.to_not raise_error
  end

  it 'only accepts a string for common_name' do
    expect { resource.common_name 78 }.to raise_error(ArgumentError)
    expect { resource.common_name :hello }.to raise_error(ArgumentError)
    expect { resource.common_name hello: :you }.to raise_error(ArgumentError)
    expect { resource.common_name 'node.fqdn' }.to_not raise_error
  end

  it 'only accepts an array for subject_alt_names' do
    expect { resource.subject_alt_names 'hello' }.to raise_error(ArgumentError)
    expect { resource.subject_alt_names :hello }.to raise_error(ArgumentError)
    expect { resource.subject_alt_names h: :y }.to raise_error(ArgumentError)
    expect { resource.subject_alt_names %w(fauxhai) }.to_not raise_error
  end

  it 'has a cert_id' do
    expect(resource.cert_id).to_not be_nil
    expect(resource.cert_id).to match(/^[a-zA-Z0-9]{64}$/)
    expect(resource.cert_id).to eq expected_cert_id
  end
end
