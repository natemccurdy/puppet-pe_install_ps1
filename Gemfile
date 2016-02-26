source 'https://rubygems.org'

group :test do
  gem "rake"
  puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['>= 4.0']
  gem 'puppet', puppetversion
  gem "rspec"
  gem "rspec-puppet"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem "rspec-puppet-utils"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end
