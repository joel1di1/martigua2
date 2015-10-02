require 'rails_helper'

RSpec.describe SendSmsJob, type: :job do
  describe ".perform" do
    let(:sms_notification) { create :sms_notification }
    let(:user) { create :user, phone_number: '0656564343' }

    it 'should call send_sms_with_blower' do
      expected_text = sms_notification.title + "\n" + sms_notification.description

      expect(Blower).to receive(:send_sms).with('+33656564343', expected_text)

      SendSmsJob.perform_later(sms_notification, user)
    end
  end
end
