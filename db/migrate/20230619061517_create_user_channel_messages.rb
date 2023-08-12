# frozen_string_literal: true

class CreateUserChannelMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :user_channel_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :channel, null: false, foreign_key: true
      t.references :message, null: false, foreign_key: true
      t.boolean :read, null: false, default: false

      t.timestamps
    end
  end
end
