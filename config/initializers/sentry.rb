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

  # Drop repeated spans matching known low-value, high-noise patterns (e.g. the
  # per-key SolidCache reads in FfhbService) before the transaction is sent, so
  # Sentry's N+1 detector never fires for them and no event/occurrence is billed.
  # See SentrySpanDeduplicator for the exact patterns; everything else is left
  # untouched so N+1 auto-detection keeps working for new violations.
  config.before_send_transaction = lambda do |event, _hint|
    event.spans = SentrySpanDeduplicator.call(event.spans)
    event
  end
end
