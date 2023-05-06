# frozen_string_literal: true

class CreateTrainingAvailabilities < ActiveRecord::Migration[4.2]
  def change
    create_table :training_availabilities do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :training, index: true, null: false
      t.boolean :available # rubocop:disable Rails/ThreeStateBooleanColumn

      t.timestamps
    end
  end
end
