# frozen_string_literal: true

class SmsNotification < ActiveRecord::Base
  belongs_to :section
  validates_presence_of :section

  after_create :send_all_sms!

  def send_all_sms!
    section.group_everybody.users.map { |user| SendSmsJob.perform_later(self, user) }
  end
end
