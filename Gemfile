source 'https://rubygems.org'

gem 'berkshelf'
gem 'unix-crypt'
gem 'chef_helpers'
gem 'chef-sugar'
gem 'fauxhai'

group :development, :test do
  gem 'guard', require: false
  gem 'rb-fsevent', require: false if RUBY_PLATFORM =~ /darwin/i
  gem 'chefspec'
  gem 'colorize', require: false
  gem 'pry-theme'
  gem 'guard-rspec', require: false
  gem 'chef-vault-testfixtures'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'reek', require: false
  gem 'flog', require: false
  gem 'ruby-lint', require: false
  gem 'ruby_gntp', require: false
  gem 'kitchen-sync', require: false
  gem 'kitchen-vagrant'
  # gem 'chef-ssl', path: '/Users/morgan/projects/ruby/oss-forks/chef-ssl-client'
  gem 'yard'
  gem 'simplecov', require: false
end

group :github_api do
  gem 'httparty'
end
