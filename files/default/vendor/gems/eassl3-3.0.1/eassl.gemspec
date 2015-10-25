# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eassl/version'

Gem::Specification.new do |spec|
  spec.name          = "eassl3"
  spec.version       = Eassl::VERSION
  spec.authors       = ["Peter Bell", "Paul Nicholson", "Paul Meserve", "Chris Andrews"]
  spec.email         = ["bellpeterm+github@gmail.com"]

#  if spec.respond_to?(:metadata)
#    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
#  end

  spec.summary       = %q{EaSSL is a library aimed at making openSSL certificate generation and management easier and more ruby-ish.}
  spec.description   = %q{This gem is a drop-in replacement for eassl 0.1.1643}
  spec.homepage      = "https://github.com/bellpeterm/eassl"
  spec.license       = "Ruby"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
