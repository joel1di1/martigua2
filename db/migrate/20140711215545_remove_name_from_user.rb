class RemoveNameFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :name
  end
end
