# frozen_string_literal: true

class AddForeignKeyOnPlayerMatchStatsTeam < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_foreign_key :player_match_stats, :teams, validate: false
  end
end
