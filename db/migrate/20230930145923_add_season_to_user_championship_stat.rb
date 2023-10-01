# frozen_string_literal: true

class AddSeasonToUserChampionshipStat < ActiveRecord::Migration[7.0]
  def change
    add_reference :user_championship_stats, :season, null: true, foreign_key: true
  end
end
