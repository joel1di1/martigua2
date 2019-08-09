# frozen_string_literal: true

class CreateMatchAvailabilities < ActiveRecord::Migration[4.2]
  def change
    create_table :match_availabilities do |t|
      t.belongs_to :match, index: true, null: false
      t.belongs_to :user, index: true, null: false
      t.boolean :available, null: false, default: false

      t.timestamps
    end
  end
end
