class RenameTrainingAvailabilityToTrainingPresence < ActiveRecord::Migration[4.2]
  def change
    rename_table :training_availabilities, :training_presences
  end
end
