# frozen_string_literal: true

class DropGueulesdeboisEvents < ActiveRecord::Migration[8.1]
  def change
    drop_table :gueulesdebois_events do |t|
      t.string :title, null: false
      t.string :event_url, null: false
      t.timestamps
    end
  end
end
