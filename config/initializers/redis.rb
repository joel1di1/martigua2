# frozen_string_literal: true

$redis = Redis.new(url: ENV['REDIS_URL']) if ENV['REDIS_URL'] # rubocop:disable Style/GlobalVars
