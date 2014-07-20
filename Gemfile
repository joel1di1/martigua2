source 'https://rubygems.org'
ruby ENV['TRAVIS'] ? '2.1.1' : '2.1.2'

gem 'rails', '4.1.4'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development
gem 'bootstrap-sass'
gem 'devise'
gem 'devise_invitable'
gem 'haml-rails'
gem 'pg'
gem 'simple_form'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'polyamorous', github: 'activerecord-hackery/polyamorous'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'formtastic', github: 'justinfrench/formtastic'
gem 'delayed_job_active_record'

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
end
group :development, :test do
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'thin'
end
group :production do
  gem 'puma'
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
