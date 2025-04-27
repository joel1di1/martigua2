# frozen_string_literal: true

class CreateSectionTrainings < ActiveRecord::Migration[6.1]
  def change
    create_table :section_trainings do |t|
      t.references :section, null: false, foreign_key: true
      t.references :training, null: false, foreign_key: true
      
      t.timestamps
    end
    
    # Add a unique index to prevent duplicate associations
    add_index :section_trainings, [:section_id, :training_id], unique: true
    
    # Copy data from sections_trainings to section_trainings
    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO section_trainings (section_id, training_id, created_at, updated_at)
          SELECT section_id, training_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM sections_trainings
        SQL
      end
    end
    
    # Don't drop the old table yet - do it in another migration after confirming everything works
    # drop_table :sections_trainings
  end
end
