# frozen_string_literal: true

# Mails nobody but the administrators receive: used to check that the transactional email
# provider (Scaleway Transactional Email) is correctly wired in a given environment.
class SystemMailer < ApplicationMailer
  # Sends the check through Scaleway and raises on failure whatever the environment
  # configures: development delivers over SMTP with raise_delivery_errors off, which would
  # turn the check into a silent no-op. Returns the message, whose recipients tell the
  # caller whether the BlockedAddress interceptor let it through.
  def self.deliver_configuration_test!(recipient)
    configuration_test(recipient).message.tap do |mail|
      mail.delivery_handler = nil
      mail.delivery_method Scaleway::TransactionalEmailDelivery
      mail.raise_delivery_errors = true
      mail.deliver
    end
  end

  def configuration_test(recipient)
    @delivery_method = Rails.application.config.action_mailer.delivery_method
    @region = ENV.fetch('SCW_REGION', Scaleway::TransactionalEmailDelivery::DEFAULT_REGION)
    @sent_at = Time.current

    mail to: recipient, subject: "[martigua] Test de configuration email (#{Rails.env})"
  end
end
