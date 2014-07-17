class Section < ActiveRecord::Base
  belongs_to :club

  has_many :team_sections
  has_many :teams, through: :team_sections 

  has_many :participations
  has_many :users, through: :participations, inverse_of: :sections

  validates_presence_of :club, :name

  def add_player!(user)
    add_user!(user, Participation::PLAYER)
  end

  def add_coach!(user)
    add_user!(user, Participation::COACH)
  end

  def players
    User.joins(:participations).where( participations: { role: Participation::PLAYER, section: self } )
  end
  
  def coachs
    User.joins(:participations).where( participations: { role: Participation::COACH, section: self } )
  end

  def to_param
    "#{self.id}-#{self.name}"
  end

  def to_s
    "Section #{self.name} - #{self.club.name}"
  end

  protected 

    def add_user!(user, role)
      params = { role: role, user: user, section: self, season: Season.current }
      participations << Participation.create!(params) unless participations.where(params).exists?
      self
    end

end
