class Section < ActiveRecord::Base
  belongs_to :club

  has_many :team_sections, dependent: :destroy
  has_many :teams, through: :team_sections

  has_many :participations, inverse_of: :section, dependent: :destroy
  has_many :users, -> { distinct }, through: :participations, inverse_of: :sections

  has_many :section_user_invitations, inverse_of: :section, dependent: :destroy
  has_and_belongs_to_many :trainings, inverse_of: :sections

  has_many :groups, inverse_of: :section, dependent: :destroy
  validates_presence_of :club, :name

  def invite_user!(params, inviter)

    raise "Inviter (#{inviter.email}) is not coach of #{self}" unless inviter.is_coach_of?(self)

    column_names = SectionUserInvitation.column_names
    column_syms = column_names.map(&:to_sym)
    params_only = params.slice(*column_syms)
    params_only_with_section = params_only.merge(section: self)
    invitation = SectionUserInvitation.create!(params_only_with_section)

    user = User.find_by_email(invitation.email)
    user ||= User.invite!(params_only.delete_if{|k, v| k.to_s == 'roles'}, inviter)

    add_user! user, params[:roles]
    user
  end

  def add_player!(user, season=nil)
    add_user!(user, Participation::PLAYER, season)
  end

  def add_coach!(user, season=nil)
    add_user!(user, Participation::COACH, season)
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

  def next_trainings
    now = DateTime.now
    end_date = (now + 2.days).end_of_week + 1.weeks
    trainings.where('start_datetime > ? AND start_datetime < ?', now, end_date)
  end

  def next_matches
    now = DateTime.now.at_beginning_of_week
    end_date = now.at_end_of_week + 2.weeks+2.days
    Match.join_day.where('COALESCE(start_datetime, days.period_start_date) >= ? AND COALESCE(start_datetime, days.period_start_date) <= ?',
      now, end_date).date_ordered.where('local_team_id IN (?) OR visitor_team_id IN (?)', teams.map(&:id), teams.map(&:id))
  end

  def group_everybody(season=nil)
    season ||= Season.current
    group = groups.where(role: :everybody, system: true, season: season).take
    unless group
      group = Group.new(role: :everybody, system: true,
                          name: 'TOUS LES MEMBRES', description: 'Tous les membres de la section',
                          color: '#226611', season: season)
      groups << group
    end
    group
  end

  def group_every_players(season=nil)
    season ||= Season.current
    group = groups.where(role: :every_players, system: true, season: season).take

    unless group
      group = Group.new(role: :every_players, system:
                        true, name: 'TOUS LES JOUEURS', description: 'Tous les joueurs de la section',
                        color: '#28c704', season: season)
      groups << group
    end
    group
  end

  def has_member?(user)
    users.include?(user)
  end

  def remove_member!(user, season=nil)
    season ||= Season.current
    participations.where(user: user, season: season).delete_all
    group_everybody(season).remove_user(user)
    group_every_players(season).remove_user(user)
  end

  def championships
    teams.includes(:championships).map(&:championships).flatten.uniq
  end

  protected

    def add_user!(user, role, season=nil)
      season ||= Season.current
      params = { role: role, user: user, section: self, season: season }
      participations << Participation.create!(params) unless participations.where(params).exists?
      group_everybody(season).add_user!(user)
      group_every_players(season).add_user!(user) if role == Participation::PLAYER
      self
    end
end
