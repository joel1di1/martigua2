class Team < ActiveRecord::Base
  belongs_to :club

  has_many :team_sections, dependent: :destroy
  has_many :sections, through: :team_sections 

  validates_presence_of :club
  validates_presence_of :name
end
