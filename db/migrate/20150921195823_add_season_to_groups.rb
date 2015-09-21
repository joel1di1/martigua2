class AddSeasonToGroups < ActiveRecord::Migration
  def change
    add_reference :groups, :season, index: true, foreign_key: true
  end
end
