# frozen_string_literal: true

class CreatePlayerMatchStats < ActiveRecord::Migration[8.1]
  def change
    create_table :player_match_stats do |t|
      t.references :match, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :player_id
      t.string :first_name
      t.string :last_name
      t.integer :jersey_number
      t.boolean :captain, default: false, null: false
      t.integer :goals, default: 0
      t.integer :seven_meters, default: 0
      t.integer :shots, default: 0
      t.integer :saves, default: 0
      t.integer :warnings, default: 0
      t.integer :two_minutes, default: 0
      t.integer :disqualifications, default: 0
      t.timestamps
    end

    add_index :player_match_stats, %i[match_id player_id], unique: true
  end
end
