# frozen_string_literal: true

class Section < ApplicationRecord
  belongs_to :club

  has_many :team_sections, dependent: :destroy, inverse_of: :section
  has_many :teams, through: :team_sections, inverse_of: :sections
  has_many :championships, -> { distinct }, through: :teams

  has_many :participations, inverse_of: :section, dependent: :destroy
  has_many :users, -> { distinct }, through: :participations, inverse_of: :sections

  has_many :section_user_invitations, inverse_of: :section, dependent: :destroy
  has_many :section_trainings, dependent: :destroy
  has_many :trainings, through: :section_trainings

  has_many :groups, inverse_of: :section, dependent: :destroy

  has_many :channels, inverse_of: :section, dependent: :destroy

  validates :name, presence: true

  after_create :create_default_channels

  def invite_user!(params, inviter)
    raise "Inviter (#{inviter.email}) is not coach of #{self}" unless inviter.coach_of?(self) || inviter.admin_of?(club)

    user = SectionInviteService.new(self, params, inviter).call

    add_user! user, params[:roles]
    user
  end

  def add_player!(user, season: nil)
    add_user!(user, Participation::PLAYER, season:)
  end

  def add_coach!(user, season: nil)
    add_user!(user, Participation::COACH, season:)
  end

  def members(season: nil)
    season ||= Season.current
    User.joins(:participations).where(participations: { season:, section: self })
  end

  def players(season: Season.current)
    User.joins(:participations).where(participations: { season:, role: Participation::PLAYER, section: self })
  end

  def coachs(season: Season.current)
    User.left_joins(:participations).where(participations: { season:, role: Participation::COACH, section: self })
  end

  def to_param
    "#{id}-#{name}"
  end

  def to_s
    "Section #{name} - #{club.name}"
  end

  def next_trainings(start_date: nil, end_date: nil)
    start_date ||= 1.day.ago
    end_date ||= (start_date + 2.days).end_of_week + 3.weeks
    trainings.where('start_datetime > ? AND start_datetime < ?', start_date, end_date)
  end

  def next_matches(start_date: nil, end_date: nil)
    now = start_date || DateTime.now.at_beginning_of_week

    end_date ||= now.at_end_of_week + 3.weeks + 2.days

    team_ids = teams.pluck(:id)

    Match.join_day.where('COALESCE(start_datetime, days.period_start_date) >= ? AND COALESCE(start_datetime, days.period_start_date) <= ?',
                         now, end_date).date_ordered.where('local_team_id IN (?) OR visitor_team_id IN (?)', team_ids, team_ids)
  end

  def group_everybody(season: nil)
    _default_group(:everybody, 'tous les membres', '#226611', season:)
  end

  def group_every_players(season: nil)
    _default_group(:every_players, 'tous les joueurs', '#28c704', season:)
  end

  def has_member?(user)
    users.include?(user)
  end

  def remove_member!(user, season: Season.current)
    participations.where(user:, season:).delete_all
    groups.where(season:).map { |group| group.remove_user! user, force: true }
  end

  def remove_roles!(user, roles, season: Season.current)
    participations.where(user:, role: roles, season:).delete_all
    group_every_players(season:).remove_user!(user, force: true) if roles.include?(Participation::PLAYER)
  end

  def update_roles!(user, roles = [])
    existing_roles = user.roles_for(self)
    remove_roles!(user, existing_roles - roles)
    add_roles!(user, roles - existing_roles)
  end

  def add_roles!(user, roles, season: Season.current)
    roles.each { |role| add_user!(user, role, season:) }
  end

  def add_user!(user, role, season: nil)
    raise "unknown role #{role}" unless Participation::ALL_ROLES.include?(role)

    season ||= Season.current
    params = { role:, user:, section: self, season: }
    participations << Participation.create!(params) unless participations.where(params).exists?
    group_everybody(season:).add_user!(user)
    group_every_players(season:).add_user!(user) if role == Participation::PLAYER
    self
  end

  def season_calendars
    Season.current.calendars
  end

  def general_channel
    channels.find_or_create_by!(system: true, name: 'Général')
  end

  def next_events(start_date: Time.zone.now, end_date: start_date + 7.days)
    (next_trainings(start_date:, end_date:) + next_matches(start_date:, end_date:)).sort_by(&:calculated_start_datetime)
  end

  protected

  def _default_group(players_role, group_name, color, season: nil)
    season ||= Season.current
    group = groups.find_by(role: players_role, system: true, season:)

    unless group
      group = Group.new(role: players_role, system: true,
                        name: group_name.upcase, description: "#{group_name.capitalize} de la section",
                        color:, season:)
      groups << group
    end
    group
  end

  def create_default_channels
    channels.find_or_create_by(system: true, name: 'Général')
  end
end
