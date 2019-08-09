# frozen_string_literal: true

class RenameAdressToAddressInLocation < ActiveRecord::Migration[4.2]
  def change
    rename_column :locations, :adress, :address
  end
end
