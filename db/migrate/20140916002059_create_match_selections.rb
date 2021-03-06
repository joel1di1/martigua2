# frozen_string_literal: true

class CreateMatchSelections < ActiveRecord::Migration[4.2]
  def change
    create_table :match_selections do |t|
      t.belongs_to :match, index: true, null: false
      t.belongs_to :team, index: true, null: false
      t.belongs_to :user, index: true, null: false

      t.timestamps
    end
  end
end
