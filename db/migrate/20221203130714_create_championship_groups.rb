# frozen_string_literal: true

class CreateChampionshipGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :championship_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
