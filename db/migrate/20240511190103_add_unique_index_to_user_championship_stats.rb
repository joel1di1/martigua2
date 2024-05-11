# frozen_string_literal: true

class AddUniqueIndexToUserChampionshipStats < ActiveRecord::Migration[7.1]
  def change
    add_index :user_championship_stats, %i[championship_id player_id], unique: true
  end
end
