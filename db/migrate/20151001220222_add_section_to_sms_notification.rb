class AddSectionToSmsNotification < ActiveRecord::Migration[4.2]
  def change
    add_reference :sms_notifications, :section, index: true, foreign_key: true
  end
end
