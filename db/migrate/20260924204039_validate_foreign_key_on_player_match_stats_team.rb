# frozen_string_literal: true

class ValidateForeignKeyOnPlayerMatchStatsTeam < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :player_match_stats, :teams
  end
end
