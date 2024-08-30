# frozen_string_literal: true

class CreateInjuries < ActiveRecord::Migration[7.2]
  def change
    create_table :injuries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_at
      t.date :end_at
      t.string :name
      t.string :comment

      t.timestamps
    end
  end
end
