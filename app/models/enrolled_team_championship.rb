class EnrolledTeamChampionship < ActiveRecord::Base
  belongs_to :team
  belongs_to :championship, inverse_of: :enrolled_team_championships

  validates_presence_of :team, :championship
end
