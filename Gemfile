source 'https://rubygems.org'
ruby '2.5.1'

gem 'rails', '~> 5.2'
gem 'coffee-rails'
gem 'sass-rails', github: 'rails/sass-rails'

gem 'activeadmin', github: 'activeadmin'
gem 'activerecord-session_store'
gem 'best_in_place'
gem 'bootstrap-sass'
gem 'colorist'
gem 'delayed_job_active_record'
gem 'devise'
gem 'devise_invitable'
gem 'font_assets'
gem 'google-api-client'
gem 'haml-rails'
gem 'kaminari'
gem 'inherited_resources', github: 'activeadmin/inherited_resources'
gem 'jbuilder'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'jquery-ui-rails'
gem 'newrelic_rpm'
gem 'nokogiri'
gem 'phony'
gem 'pg', group: [:production, :development]
gem 'polyamorous', github: 'activerecord-hackery/polyamorous'
gem 'puma'
gem 'rack-cors', :require => 'rack/cors'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'redis'
gem 'rest-client'
gem 'sdoc',  group: :doc
gem 'simple_form'
gem 'starburst', '~> 1.0'
gem 'switch_user'
gem 'turbolinks'
gem 'twilio-ruby'
gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'active_record_query_trace'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'html2haml'
  gem 'query_diet'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'web-console'
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

  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: false
end
