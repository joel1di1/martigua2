# frozen_string_literal: true

class CreateUserChampionshipStats < ActiveRecord::Migration[7.0]
  def change
    create_table :user_championship_stats do |t|
      t.references :user, foreign_key: true
      t.references :championship, null: false, foreign_key: true
      t.integer :match_played
      t.integer :goals
      t.integer :saves
      t.integer :goal_average
      t.integer :save_average
      t.string :player_id
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
