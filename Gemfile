# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'rails', '~> 7.0.4'

gem 'activerecord-session_store'
gem 'administrate'
gem 'bcrypt'
gem 'bootsnap', require: false
gem 'colorist'
gem 'delayed_job_active_record'
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
gem 'newrelic_rpm'
gem 'oj'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'
gem 'rails_ping'
gem 'redis'
gem 'sentry-delayed_job'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sidekiq'
gem 'simple_form'
gem 'simple_form-tailwind'
gem 'slim'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'switch_user'
gem 'tailwindcss-rails'
gem 'turbo-rails'
gem 'twilio-ruby'

group :production do
  gem 'postmark-rails'
end

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

group :development, :test do
  gem 'debug'
  gem 'factory_bot_rails'
  gem 'foreman', require: false
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'rack-mini-profiler'
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
  gem 'timecop'
  gem 'webdrivers'
  gem 'capybara-webkit'
end
