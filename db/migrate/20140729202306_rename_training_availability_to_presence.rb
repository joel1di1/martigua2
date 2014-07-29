class RenameTrainingAvailabilityToPresence < ActiveRecord::Migration
  def change
    rename_column :training_presences, :available, :present
  end
end
