# Eassl

EaSSL is a library aimed at making openSSL certificate generation and management easier and more ruby-ish.

Forked from https://github.com/chrisa/eassl and patched using available pull requests for that project and additional development for better utilizing CSR details and using SHA512 for signing by default.  Rcov and Jeweler were switched out in favor of Rspec and Bundler.
 
Ruby license, inherited from the rubyforge project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eassl3'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eassl3

## Usage

Generating a CSR and private key:
    options = {
      :department     => 'web sites',
      :common_name    => 'www.mydomain.com',
      :organization,  => 'My Org'
      :email          => 'test@test.com',
      :city           => 'Fargo',
      :state          => 'North Dakota',
      :country        => 'USA',
      :subject_alt_name => ['www.mydomain.com', 'mydomain.com']
    }

    ea_key  = EaSSL::Key.new
    ea_name = EaSSL::CertificateName.new(options)
    ea_csr  = EaSSL::SigningRequest.new(:name => ea_name, :key => ea_key)

    csr = ea_csr.ssl.to_s
    key = ea_key.private_key.to_s

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/eassl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
