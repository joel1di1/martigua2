# frozen_string_literal: true

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Ensure Devise mappings are loaded for model tests
  config.before(:suite) do
    # Force Devise to reload mappings to avoid "Could not find a valid mapping" errors
    # when running isolated tests
    Rails.application.reload_routes! if Devise.mappings.empty?
  end
end
