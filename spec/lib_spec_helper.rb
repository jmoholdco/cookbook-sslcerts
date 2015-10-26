require 'rspec'
require 'simplecov'
require_relative 'unit/resources/shared_examples'
SimpleCov.start do
  add_filter '/files/default/vendor'
  add_filter '/spec/'
end

require './libraries/helpers'
require './libraries/mixin'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.order = :random
  config.default_formatter = 'doc' if config.files_to_run.one?
  Kernel.srand config.seed
end

def rhel?(platform)
  %w(centos redhat).include? platform
end
