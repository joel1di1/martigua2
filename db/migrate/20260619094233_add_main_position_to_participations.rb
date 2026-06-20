# frozen_string_literal: true

class AddMainPositionToParticipations < ActiveRecord::Migration[8.1]
  def change
    add_column :participations, :main_position, :string
  end
end
