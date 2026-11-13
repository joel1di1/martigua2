# frozen_string_literal: true

class DropAdminUsers < ActiveRecord::Migration[8.1]
  def up
    safety_assured { drop_table :admin_users }
  end

  def down
    create_table :admin_users do |t|
      t.string :email, null: false, default: ''
      t.string :encrypted_password, null: false, default: ''
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
      t.timestamps null: true
    end
    add_index :admin_users, :email, unique: true
    add_index :admin_users, :reset_password_token, unique: true
  end
end
