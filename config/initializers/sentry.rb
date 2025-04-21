# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV.fetch('SENTRY_DSN', nil)
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:

  config.traces_sample_rate = Rails.env.development? ? 0.0 : 0.25

  # or
  # config.traces_sampler = lambda do |_context|
  #   true
  # end
end
