# frozen_string_literal: true

class CreateChampionshipGroupChampionships < ActiveRecord::Migration[7.0]
  def change
    create_table :championship_group_championships do |t|
      t.references :championship, null: false, foreign_key: true
      t.references :championship_group, null: false, foreign_key: true
      t.integer :index, null: false

      t.timestamps
    end
  end
end
