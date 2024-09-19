# frozen_string_literal: true

$redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:63791/0')) # rubocop:disable Style/GlobalVars
