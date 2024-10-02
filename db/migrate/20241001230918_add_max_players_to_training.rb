# frozen_string_literal: true

class AddMaxPlayersToTraining < ActiveRecord::Migration[7.2]
  def change
    add_column :trainings, :max_capacity, :integer
  end
end
