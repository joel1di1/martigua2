# frozen_string_literal: true

require 'twilio-ruby'

class SendSmsJob < ActiveJob::Base
  queue_as :default

  TWILIO_ACCOUNT_ID = ENV['TWILIO_ACCOUNT_ID']
  TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']
  TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER']

  def perform(sms_notification, user)
    return if user.phone_number.blank?

    france = Phony['33']
    phone_number = france.normalize(france.format(user.phone_number, format: :local))
    return unless france.plausible?(phone_number)

    phone_number = france.normalize(france.format(phone_number, format: :international))
    phone_number = "+#{phone_number}"
    text = "#{sms_notification.title}\n#{sms_notification.description}"

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new TWILIO_ACCOUNT_ID, TWILIO_AUTH_TOKEN

    @client.messages.create(
      from: TWILIO_PHONE_NUMBER,
      to: phone_number,
      body: text
    )
  end
end
