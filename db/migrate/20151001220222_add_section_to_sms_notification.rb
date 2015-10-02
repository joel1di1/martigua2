class AddSectionToSmsNotification < ActiveRecord::Migration
  def change
    add_reference :sms_notifications, :section, index: true, foreign_key: true
  end
end
