source 'https://rubygems.org'
ruby ENV['TRAVIS'] ? '2.1.1' : '2.1.2'

gem 'rails', '4.2.4'
gem 'coffee-rails'
gem 'sass-rails'

gem 'activeadmin', github: 'activeadmin'
gem 'activerecord-session_store'
gem 'bootstrap-sass'
gem 'colorist'
gem 'delayed_job_active_record'
gem 'devise'
gem 'devise_invitable'
gem 'font_assets'
gem 'haml-rails'
gem 'heroku-api'
gem 'kaminari'
gem 'jbuilder'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'jquery-minicolors-rails'
gem 'newrelic_rpm'
gem 'nokogiri'
gem 'pg', group: [:production, :development]
gem 'polyamorous', github: 'activerecord-hackery/polyamorous'
gem 'puma'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'rest-client'
gem 'sdoc',  group: :doc
gem 'simple_form'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'html2haml'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
  gem 'spring'
end

group :development, :test do
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'foreman'
end
group :production do
  gem 'heroku-deflater'
  gem 'oboe-heroku'
  gem 'postmark-rails'
  gem 'rails_12factor'
end
group :test do
  gem "sqlite3", :platform => [:ruby, :mswin, :mingw]
  gem "jdbc-sqlite3", :platform => :jruby  
  
  gem "codeclimate-test-reporter", require: nil

  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: false
end
