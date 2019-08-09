# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.text :adress

      t.timestamps
    end
  end
end
