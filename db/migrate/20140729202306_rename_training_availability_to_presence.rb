# frozen_string_literal: true

class RenameTrainingAvailabilityToPresence < ActiveRecord::Migration[4.2]
  def change
    rename_column :training_presences, :available, :present
  end
end
