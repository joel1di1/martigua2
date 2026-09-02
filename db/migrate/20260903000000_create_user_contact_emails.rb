# frozen_string_literal: true

class CreateUserContactEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :user_contact_emails do |t|
      t.references :user, null: false, foreign_key: true
      t.string :email, null: false
      t.string :label

      t.timestamps
    end

    add_index :user_contact_emails, %i[user_id email], unique: true
  end
end
