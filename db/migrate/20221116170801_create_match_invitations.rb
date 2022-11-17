# frozen_string_literal: true

class CreateMatchInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :match_invitations do |t|
      t.references :match, null: false, foreign_key: true
      t.references :user, null: true

      t.timestamps
    end
  end
end
