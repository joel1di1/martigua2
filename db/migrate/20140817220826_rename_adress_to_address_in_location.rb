class RenameAdressToAddressInLocation < ActiveRecord::Migration
  def change
    rename_column :locations, :adress, :address
  end
end
