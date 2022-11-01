# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'd27sj2p8c08vei.cloudfront.net'
    resource '*', headers: :any, methods: %i[get head options]
  end
end
