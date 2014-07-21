class Section < ActiveRecord::Base
  belongs_to :club

  has_many :team_sections, dependent: :destroy
  has_many :teams, through: :team_sections 

  has_many :participations, inverse_of: :section, dependent: :destroy
  has_many :users, through: :participations, inverse_of: :sections

  has_many :section_user_invitations, inverse_of: :section, dependent: :destroy


  validates_presence_of :club, :name

  def invite_user!(params, inviter)

    raise "Inviter (#{inviter.email}) is not coach of #{self}" unless inviter.is_coach_of?(self)

    column_names = SectionUserInvitation.column_names
    column_syms = column_names.map(&:to_sym)
    params_only = params.slice(*column_syms)
    params_only_with_section = params_only.merge(section: self)
    invitation = SectionUserInvitation.create!(params_only_with_section)

    user = User.find_by_email(invitation.email)
    if user
    else
      user = User.invite!(params_only.delete_if{|k, v| k.to_s == 'roles'}, inviter)
    end

    add_user! user, params[:roles]
    user
  end

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
