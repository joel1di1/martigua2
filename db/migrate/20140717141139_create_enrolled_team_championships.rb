class CreateEnrolledTeamChampionships < ActiveRecord::Migration
  def change
    create_table :enrolled_team_championships do |t|
      t.belongs_to :team, index: true, false: true
      t.belongs_to :championship, index: true, false: true

      t.timestamps
    end
  end
end
