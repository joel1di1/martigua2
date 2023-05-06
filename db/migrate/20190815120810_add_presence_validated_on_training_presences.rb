# frozen_string_literal: true

class AddPresenceValidatedOnTrainingPresences < ActiveRecord::Migration[5.1]
  def change
    add_column :training_presences, :presence_validated, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
