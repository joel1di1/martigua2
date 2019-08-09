# frozen_string_literal: true

class CreateTrainings < ActiveRecord::Migration[4.2]
  def change
    create_table :trainings do |t|
      t.datetime :start_datetime, null: false
      t.datetime :end_datetime
      t.belongs_to :location, index: true
      t.boolean :canceled
      t.text :cancelation_reason

      t.timestamps
    end

    create_table :sections_trainings, id: false do |t|
      t.belongs_to :training, null: false
      t.belongs_to :section, null: false
    end
  end
end
