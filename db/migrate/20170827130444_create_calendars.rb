# frozen_string_literal: true

class CreateCalendars < ActiveRecord::Migration[5.1]
  def change
    create_table :calendars do |t|
      t.references :season, foreign_key: true, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
