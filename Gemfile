source 'https://rubygems.org'
gemspec

gem 'rest-client', '< 1.7' if RUBY_VERSION == '1.8.7' # 1.7.0 drops support for ruby 1.8.7

group :development do
  gem 'pry'
  gem 'smart_proxy', :github => "theforeman/smart-proxy", :branch => 'develop'
  gem 'addressable', '~> 2.3.8' if RUBY_VERSION == '1.8.7' # 2.4.0 drops support for ruby 1.8.7
end
