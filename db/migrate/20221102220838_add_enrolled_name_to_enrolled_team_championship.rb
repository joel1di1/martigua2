# frozen_string_literal: true

class AddEnrolledNameToEnrolledTeamChampionship < ActiveRecord::Migration[7.0]
  def change
    add_column :enrolled_team_championships, :enrolled_name, :string
  end
end
