class RenameDiscussionsToChannels < ActiveRecord::Migration[7.0]
  def change
    rename_table :discussions, :channels
  end
end
