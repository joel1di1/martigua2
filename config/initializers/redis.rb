# frozen_string_literal: true

if ENV["REDIS_URL"]
  $redis = Redis.new(:url => ENV["REDIS_URL"])
end