# frozen_string_literal: true

class AddSelectionsHiddenToDays < ActiveRecord::Migration[7.2]
  def change
    add_column :days, :selection_hidden, :boolean, default: false, null: false
  end
end
