notification :gntp, host: '127.0.0.1'

group :recipes do
  rspec_opts = {
    cmd: 'rspec',
    failed_mode: :focus
  }
  guard :rspec, rspec_opts do
    watch(%r{^spec/.+_spec\.rb$})
    watch('spec/spec_helper.rb') { 'spec' }
    watch(%r{^spec/(.+)/shared_examples\.rb$}) { 'spec' }
    watch(%r{^recipes/(.+)\.rb$}) { |m| "spec/unit/recipes/#{m[1]}_spec.rb" }
    watch(%r{^attributes/(.+)\.rb$}) { |m| "spec/unit/recipes/#{m[1]}_spec.rb" }
    watch(%r{^libraries/(.+)_ca_certificate\.rb$}) do
      'spec/unit/recipes/lwrp_certificate_authority_spec.rb'
    end
    watch(%r{^libraries/(.+)_ssl_certificate\.rb$}) do
      'spec/unit/recipes/lwrp_certificate_spec.rb'
    end
  end
end

group :libraries do
  rspec_opts = {
    cmd: 'rspec',
    failed_mode: :focus,
    spec_paths: %w(spec/unit/resources spec/unit/providers),
    run_all: {
      cmd: 'rspec spec/unit/resources spec/unit/providers'
    }
  }

  guard :rspec, rspec_opts do
    watch(%r{^spec/unit/(resources|providers)/(.+)\.rb$})
    watch('spec/lib_spec_helper.rb') { 'spec' }

    watch(%r{^libraries/resource_(.+)\.rb$}) do |m|
      "spec/unit/resources/#{m[1]}_spec.rb"
    end

    watch(%r{^libraries/provider_(.+)\.rb$}) do |m|
      "spec/unit/providers/#{m[1]}_spec.rb"
    end

    watch(%r{^libraries/mixin\.rb$}) { 'spec/unit/resources' }
    watch('spec/unit/resources/shared_examples.rb') { 'spec/unit/resources' }
  end
end

#  vim: set ts=8 sw=2 tw=0 ft=ruby et :
