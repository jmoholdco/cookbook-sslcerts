require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-vault/test_fixtures'
require_relative 'unit/recipes/shared_examples'
ChefSpec::Coverage.start!

RSpec.configure do |config|
  config.include ChefVault::TestFixtures.rspec_shared_context(true)
  config.file_cache_path = '/var/chef/cache'
  # config.fail_fast = true
end
