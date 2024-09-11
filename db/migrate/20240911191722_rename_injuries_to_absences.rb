# frozen_string_literal: true

class RenameInjuriesToAbsences < ActiveRecord::Migration[7.2]
  def change
    rename_table :injuries, :absences
  end
end
