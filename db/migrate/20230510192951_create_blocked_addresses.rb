# frozen_string_literal: true

class CreateBlockedAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :blocked_addresses do |t|
      t.string :email, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
