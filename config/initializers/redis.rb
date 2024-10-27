# frozen_string_literal: true

$redis = Redis.new( # rubocop:disable Style/GlobalVars
  url: ENV.fetch('REDIS_URL', 'redis://localhost:63791/0'),
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
)
