notification :gntp, host: '127.0.0.1'

group :recipes do
  rspec_opts = {
    cmd: 'rspec',
    failed_mode: :focus,
    spec_paths: %w(spec/unit/recipes),
    results_file: 'tmp/guard_rspec_recipes.txt'
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
    spec_paths: %w(spec/unit/resources spec/unit/providers spec/unit/libraries),
    run_all: {
      cmd: 'rspec spec/unit/resources spec/unit/providers'
    }
  }

  guard :rspec, rspec_opts do
    watch(%r{^spec/unit/(resources|providers|libraries)/(.+)\.rb$})
    watch('spec/lib_spec_helper.rb') do
      %w(spec/unit/resources spec/unit/providers spec/unit/libraries)
    end

    watch(%r{^libraries/resource_(.+)\.rb$}) do |m|
      "spec/unit/resources/#{m[1]}_spec.rb"
    end

    watch(%r{^libraries/provider_(.+)\.rb$}) do |m|
      "spec/unit/providers/#{m[1]}_spec.rb"
    end

    watch(%r{^libraries/mixin_(.+)\.rb$}) do |m|
      case m[1]
      when /resource/, /cert_request/ then 'spec/unit/resources'
      when /provider/ then 'spec/unit/providers'
      else '/spec/unit/providers'
      end
    end

    watch('spec/unit/resources/shared_examples.rb') { 'spec/unit/resources' }

    watch('libraries/utils.rb') { 'spec/unit/libraries/utils_spec.rb' }
  end
end

#  vim: set ts=8 sw=2 tw=0 ft=ruby et :
