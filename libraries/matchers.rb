if defined?(ChefSpec)
  def create_x509_certificate(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sslcerts_x509, :create, name)
  end

  def create_rsa_key(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sslcerts_rsa_key, :create, name)
  end
end
