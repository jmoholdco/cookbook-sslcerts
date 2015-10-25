# -*- encoding: utf-8 -*-
# stub: eassl3 3.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "eassl3"
  s.version = "3.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Peter Bell", "Paul Nicholson", "Paul Meserve", "Chris Andrews"]
  s.bindir = "exe"
  s.date = "2015-07-02"
  s.description = "This gem is a drop-in replacement for eassl 0.1.1643"
  s.email = ["bellpeterm+github@gmail.com"]
  s.homepage = "https://github.com/bellpeterm/eassl"
  s.licenses = ["Ruby"]
  s.rubygems_version = "2.4.8"
  s.summary = "EaSSL is a library aimed at making openSSL certificate generation and management easier and more ruby-ish."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.8"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.8"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.8"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
