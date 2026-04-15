# frozen_string_literal: true

class CreateGueulesdeboisEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :gueulesdebois_events do |t|
      t.string :title, null: false
      t.string :event_url, null: false

      t.timestamps
    end

    add_index :gueulesdebois_events, :event_url, unique: true
  end
end
