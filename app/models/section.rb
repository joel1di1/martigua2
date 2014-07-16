class Section < ActiveRecord::Base
  belongs_to :club

  has_many :team_sections
  has_many :teams, through: :team_sections 

  has_many :participations
  has_many :users, through: :participations

  validates_presence_of :club, :name

  def add_player(user)
    participations << Participation.create!(role: Participation::PLAYER, user: user, section: self, season: Season.current)
    self
  end

  def players
    User.joins(:participations).where( participations: { role: Participation::PLAYER, section: self } )
  end

  def to_param
    "#{self.id}-#{self.name}"
  end

end
