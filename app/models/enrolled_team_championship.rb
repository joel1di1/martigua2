class EnrolledTeamChampionship < ActiveRecord::Base
  belongs_to :team
  belongs_to :championship

  validates_presence_of :team, :championship
end
