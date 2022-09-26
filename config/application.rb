# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Martigua2
  class Application < Rails::Application
    config.time_zone = 'Paris'
    config.active_record.default_timezone = :local

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'd1zljy12d9ls0t.cloudfront.net'
        resource '*', headers: :any, methods: %i[get head options]
      end
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.active_record.schema_format = :sql
    config.active_record.legacy_connection_handling = false

    # TODO: remove when get rid of scss
    config.assets.css_compressor = nil
  end
end
