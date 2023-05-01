# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :channel, null: false, foreign_key: true
      t.text :content, null: false
      t.references :parent_message, index: true, foreign_key: { to_table: :messages }

      t.timestamps
    end
  end
end
