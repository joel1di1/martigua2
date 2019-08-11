# frozen_string_literal: true

class CreateDutyTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :duty_tasks do |t|
      t.string :name, null: false
      t.belongs_to :user, foreign_key: true, null: false
      t.datetime :realised_at

      t.timestamps
    end
  end
end
