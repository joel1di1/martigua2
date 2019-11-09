# frozen_string_literal: true

require 'twilio-ruby'

class SendSmsJob < ActiveJob::Base
  queue_as :default

  def perform(sms_notification, user)
    # put your own credentials here
    account_sid = ENV['TWILIO_ACCOUNT_ID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    twilio_phone_number = ENV['TWILIO_PHONE_NUMBER']

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new account_sid, auth_token

    # alternatively, you can preconfigure the client like so
    Twilio.configure do |config|
      config.account_sid = account_sid
      config.auth_token = auth_token
    end

    # and then you can create a new client without parameters
    @client = Twilio::REST::Client.new

    if user.phone_number
      france = Phony["33"]
      phone_number = france.normalize(france.format(user.phone_number, format: :local))
      if france.plausible?(phone_number)
        phone_number = france.normalize(france.format(phone_number, format: :international))
        phone_number = "+#{phone_number}"
        text = "#{sms_notification.title}\n#{sms_notification.description}"

        @client.messages.create(
          from: twilio_phone_number,
          to: phone_number,
          body: text
        )
      end
    end
  end
end
