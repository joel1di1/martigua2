# frozen_string_literal: true

class AddFfhbTeamIdToEnrolledTeamChampionship < ActiveRecord::Migration[7.0]
  def change
    add_column :enrolled_team_championships, :ffhb_team_id, :string
  end
end
