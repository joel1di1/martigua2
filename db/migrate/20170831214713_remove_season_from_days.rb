class RemoveSeasonFromDays < ActiveRecord::Migration[5.1]
  def up
    remove_column :days, :season_id, :reference
  end
  def down
    add_reference :days, :season
  end
end
