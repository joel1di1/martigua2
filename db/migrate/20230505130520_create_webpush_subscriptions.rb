# frozen_string_literal: true

class CreateWebpushSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :webpush_subscriptions do |t|
      t.string :endpoint
      t.string :p256dh_key
      t.string :auth_key
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
