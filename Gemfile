source 'https://rubygems.org'

group :test do
  gem 'database_cleaner'
end
# Specify your gem's dependencies in voynich.gemspec
gemspec

version = ENV['AR_VERSION'] || '5.0'
eval_gemfile File.expand_path("../gemfiles/#{version}.gemfile", __FILE__)
