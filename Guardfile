notification :gntp, host: '127.0.0.1'

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
end

#  vim: set ts=8 sw=2 tw=0 ft=ruby et :
