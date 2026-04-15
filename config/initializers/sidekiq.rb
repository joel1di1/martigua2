# frozen_string_literal: true

if ENV['REDIS_URL']
  Sidekiq.configure_server do |config|
    config.redis = {
      url: ENV['REDIS_URL'],
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
      network_timeout: 5
    }

    schedule = YAML.load_file(Rails.root.join('config/sidekiq.yml'))[:schedule]
    Sidekiq::Cron::Job.load_from_hash!(schedule)
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: ENV['REDIS_URL'],
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
      network_timeout: 5
    }
  end
end
