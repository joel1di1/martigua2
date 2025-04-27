# frozen_string_literal: true

class CreateGroupTrainings < ActiveRecord::Migration[6.1]
  def change
    create_table :group_trainings do |t|
      t.references :group, null: false, foreign_key: true
      t.references :training, null: false, foreign_key: true
      
      t.timestamps
    end
    
    # Add a unique index to prevent duplicate associations
    add_index :group_trainings, [:group_id, :training_id], unique: true
    
    # Copy data from groups_trainings to group_trainings
    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO group_trainings (group_id, training_id, created_at, updated_at)
          SELECT group_id, training_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM groups_trainings
        SQL
      end
    end
    
    # Don't drop the old table yet - do it in another migration after confirming everything works
    # drop_table :groups_trainings
  end
end
