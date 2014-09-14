class Team < ActiveRecord::Base
  belongs_to :club

  has_many :team_sections, dependent: :destroy
  has_many :sections, through: :team_sections 

  has_many :enrolled_team_championships
  has_many :championships, through: :enrolled_team_championships

  validates_presence_of :club
  validates_presence_of :name
end
