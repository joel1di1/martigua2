# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Martigua2
  class Application < Rails::Application
    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    config.time_zone = 'Paris'
    config.active_record.default_timezone = :local

    config.active_job.queue_adapter = :delayed_job

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'd1zljy12d9ls0t.cloudfront.net'
        resource '*', :headers => :any, :methods => [:get, :head, :options]
      end
    end

    sentry_dsn = ENV['SENTRY_DSN']
    if sentry_dsn
      Raven.configure do |config|
        config.dsn = sentry_dsn
      end
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
