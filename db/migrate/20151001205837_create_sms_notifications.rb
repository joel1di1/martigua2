class CreateSmsNotifications < ActiveRecord::Migration
  def change
    create_table :sms_notifications do |t|
      t.string :title
      t.text :description

      t.timestamps null: false
    end
  end
end
