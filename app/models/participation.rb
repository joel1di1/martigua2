class Participation < ActiveRecord::Base

  PLAYER = 'player'
  COACH = 'coach'

  belongs_to :user
  belongs_to :section
  belongs_to :season

  validates_presence_of :user
  validates_presence_of :season
  validates_presence_of :section
  validates_presence_of :role

  scope :coachs, where(role: COACH)

end
