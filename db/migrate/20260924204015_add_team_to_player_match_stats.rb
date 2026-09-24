# frozen_string_literal: true

class AddTeamToPlayerMatchStats < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :player_match_stats, :team, index: { algorithm: :concurrently }
  end
end
