# frozen_string_literal: true

class RenamePresentToIsPresent < ActiveRecord::Migration[5.2]
  def change
    rename_column :training_presences, :present, :is_present
  end
end
