require 'helper'

class TestEasslCertificateAuthority < Test::Unit::TestCase

  def test_new_certificate
    key = EaSSL::Key.new
    cacert = EaSSL::AuthorityCertificate.new(:key => key)
    assert cacert
    assert_equal "/CN=CA", cacert.subject.to_s
    assert_equal "/CN=CA", cacert.issuer.to_s
  end

  def test_load_certificate
    cacert_path = File.join(File.dirname(__FILE__), 'CA', 'cacert.pem')
    cacert = EaSSL::AuthorityCertificate.load(cacert_path)
    assert cacert
    assert_equal "/C=US/O=Venda/OU=auto-CA/CN=CA", cacert.subject.to_s
    assert_equal "/C=US/O=Venda/OU=auto-CA/CN=CA", cacert.issuer.to_s
  end

  def test_certificate_from_text
    cacert_text = <<CACERT
-----BEGIN CERTIFICATE-----
MIICyzCCAjSgAwIBAgIBADANBgkqhkiG9w0BAQUFADA8MQswCQYDVQQGEwJVUzEO
MAwGA1UECgwFVmVuZGExEDAOBgNVBAsMB2F1dG8tQ0ExCzAJBgNVBAMMAkNBMB4X
DTExMTIwNjE3NDE1M1oXDTIxMTIwMzE3NDE1M1owPDELMAkGA1UEBhMCVVMxDjAM
BgNVBAoMBVZlbmRhMRAwDgYDVQQLDAdhdXRvLUNBMQswCQYDVQQDDAJDQTCBnzAN
BgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAu8QKXQjfp9mbf8GLzBy95l4QWJspeLiv
GvYUgxDl9q3q+C37s/px8LIdDhSXp+bL0gUTzL1/DUNKoMkYZZ2Lozdlg0gp7eQ6
1M7baDveuKeD86U1pCdBZiPIlBAUny8qxe1AvetSrLYH1RV4An68+lKKlj8o/pOQ
T6u4XnHIwNkCAwEAAaOB3DCB2TAPBgNVHRMBAf8EBTADAQH/MDEGCWCGSAGG+EIB
DQQkFiJSdWJ5L09wZW5TU0wgR2VuZXJhdGVkIENlcnRpZmljYXRlMB0GA1UdDgQW
BBT+n8Ml3oKlSBBaeaaDrWFS9THk5TAOBgNVHQ8BAf8EBAMCAQYwZAYDVR0jBF0w
W4AU/p/DJd6CpUgQWnmmg61hUvUx5OWhQKQ+MDwxCzAJBgNVBAYTAlVTMQ4wDAYD
VQQKDAVWZW5kYTEQMA4GA1UECwwHYXV0by1DQTELMAkGA1UEAwwCQ0GCAQAwDQYJ
KoZIhvcNAQEFBQADgYEABpz5uxouNMgKxVtjsiLDaD8XfpfRgM8J7H6uP9dpzZf1
GkCNWN9DPI/uTF9sXkZ9nXA8U85MX9EfgBL0E9gyIocKeGn24X32X3CtbP1fH0n1
dL2rzIwcDTHJahnkXu2icQbp59DKx1+Od/vfvQwKwZxMWrUWjzB+O8+kgKoMOlg=
-----END CERTIFICATE-----
CACERT
    cacert = EaSSL::AuthorityCertificate.new({}).load(cacert_text)
    assert cacert
    assert_equal "/C=US/O=Venda/OU=auto-CA/CN=CA", cacert.subject.to_s
    assert_equal "/C=US/O=Venda/OU=auto-CA/CN=CA", cacert.issuer.to_s
  end

  def test_load_nonexistent_file
    assert_raises Errno::ENOENT do
      key = EaSSL::AuthorityCertificate.load('./foo')
    end
  end

  def test_load_bad_file
    file = File.join(File.dirname(__FILE__), '..', 'Rakefile')
    assert_raises RuntimeError do
      key = EaSSL::AuthorityCertificate.load(file)
    end
  end

end
