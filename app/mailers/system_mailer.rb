# frozen_string_literal: true

# Mail sent by `rake solid:check` to a given user, to check that the whole queue chain —
# adapter, ActiveRecordAsyncJob and the transactional email provider — works end to end.
class SystemMailer < ApplicationMailer
  # Smoke test for the Solid Queue migration (issue #1191): enqueued by `rake solid:check`
  # through the async_ dynamic method, so it exercises the whole chain — queue adapter,
  # ActiveRecordAsyncJob and the delivery provider.
  def solid_check(user)
    @delivery_method = Rails.application.config.action_mailer.delivery_method
    @sent_at = Time.current

    mail to: user.email, subject: "[martigua] Vérification Solid Queue (#{Rails.env}) - #{@sent_at}"
  end
end
