class RenameTrainingAvailabilityToTrainingPresence < ActiveRecord::Migration
  def change
    rename_table :training_availabilities, :training_presences
  end
end
