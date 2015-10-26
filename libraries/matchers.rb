if defined?(ChefSpec)
  def create_ssl_certificate(name)
    ChefSpec::Matchers::ResourceMatcher.new(:ssl_certificate, :create, name)
  end

  def create_ca_certificate(name)
    ChefSpec::Matchers::ResourceMatcher.new(:ca_certificate, :create, name)
  end
end
