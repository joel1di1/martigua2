# frozen_string_literal: true

# Mails nobody but the administrators receive: used to check that the transactional email
# provider (Scaleway Transactional Email) is correctly wired in a given environment.
class SystemMailer < ApplicationMailer
  def configuration_test(recipient)
    @delivery_method = Rails.application.config.action_mailer.delivery_method
    @region = ENV.fetch('SCW_REGION', Scaleway::TransactionalEmailDelivery::DEFAULT_REGION)
    @sent_at = Time.current

    mail to: recipient, subject: "[martigua] Test de configuration email (#{Rails.env})"
  end
end
