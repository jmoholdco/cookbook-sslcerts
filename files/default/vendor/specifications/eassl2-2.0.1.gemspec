# -*- encoding: utf-8 -*-
# stub: eassl2 2.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "eassl2"
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Paul Nicholson", "Paul Meserve", "Chris Andrews"]
  s.date = "2013-02-03"
  s.description = "This gem is a more featureful but still drop-in replacement for eassl 0.1.1643"
  s.email = "chris@nodnol.org"
  s.extra_rdoc_files = ["LICENSE.txt", "README.txt"]
  s.files = ["LICENSE.txt", "README.txt"]
  s.homepage = "http://github.com/chrisa/eassl"
  s.licenses = ["Ruby"]
  s.rubygems_version = "2.4.8"
  s.summary = "EaSSL is a library aimed at making openSSL certificate generation and management easier and more ruby-ish."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end
