class SendSmsJob < ActiveJob::Base
  queue_as :default

  def perform(sms_notification, user)
    if user.phone_number
      france = Phony["33"]
      phone_number = france.normalize(france.format(user.phone_number, :format => :local))
      if france.plausible?(phone_number)
        phone_number = france.normalize(france.format(phone_number, :format => :international))
        phone_number = "+#{phone_number}"
        text = "#{sms_notification.title}\n#{sms_notification.description}"
        Blower.send_sms(phone_number, text)
      end
    end
  end
end
