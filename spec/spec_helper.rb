require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-vault/test_fixtures'

RSpec.configure do |config|
  config.include ChefVault::TestFixtures.rspec_shared_context, vault: true
  config.platform = 'centos'
  config.version = '7.1.1503'
end
