class Championship < ActiveRecord::Base
  belongs_to :season
  has_many :enrolled_team_championships, inverse_of: :championship, dependent: :destroy
  has_many :teams, through: :enrolled_team_championships 
  has_many :matches, inverse_of: :championship, dependent: :destroy

  validates_presence_of :name
  validates_presence_of :season

  def enroll_team!(team)
    teams << team unless teams.include?(team)
    self
  end

  def enrolled_teams
    teams
  end

end
