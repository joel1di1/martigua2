# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'

gem 'rails', '~> 8.0'

gem 'activerecord-session_store'
gem 'administrate'
gem 'aws-sdk-s3', require: false
gem 'bcrypt'
gem 'bootsnap', require: false
gem 'colorist'
gem 'devise'
gem 'devise-i18n'
gem 'devise_invitable'
gem 'google-api-client'
gem 'haml-rails'
gem 'icalendar'
gem 'importmap-rails'
gem 'jbuilder'
gem 'kaminari'
gem 'net-imap'
gem 'net-pop'
gem 'net-smtp'
gem 'oj'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'
gem 'rails_ping'
gem 'redis'
gem 'scout_apm'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
gem 'sidekiq'
gem 'simple_form'
gem 'simple_form-tailwind'
gem 'slim'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'string-similarity'
gem 'switch_user'
gem 'tailwindcss-rails', '~> 4.3'
gem 'turbo-rails'
gem 'watir'
gem 'web-push'

# newrelic must be after scout_apm
gem 'newrelic_rpm'

group :production do
  gem 'postmark-rails'
end

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.14'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

group :development, :test do
  gem 'brakeman', require: false
  gem 'debug'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'foreman', require: false
  gem 'parallel_tests'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end

group :development do
  gem 'derailed_benchmarks', group: :development, git: 'https://github.com/rzilient-club/derailed_benchmarks.git'
  gem 'rack-mini-profiler'
  gem 'ruby-lsp'
  gem 'ruby-lsp-rspec'
  gem 'stackprof', group: :development
  gem 'web-console'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'rspec-its'
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
  gem 'simplecov_json_formatter', require: false
  gem 'timecop'
end
