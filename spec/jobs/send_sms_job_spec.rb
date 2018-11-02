require 'rails_helper'

RSpec.describe SendSmsJob, type: :job do
  describe ".perform", skip: "SMS tests are skipped (need to pay for real tests)" do
    let(:sms_notification) { create :sms_notification }
    let(:user) { create :user, phone_number: '0656564343' }

    it 'sends SMS' do
      expected_text = sms_notification.title + "\n" + sms_notification.description

      messages = double("Messages")

      expect_any_instance_of(Twilio::REST::Client).to receive(:messages).and_return(messages)

      expect(messages).to receive(:create).with(
        from: '+33644605525',
        to: '+33656564343',
        body: expected_text
      )

      SendSmsJob.perform_later(sms_notification, user)
    end
  end
end
