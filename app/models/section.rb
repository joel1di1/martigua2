# frozen_string_literal: true

class Section < ActiveRecord::Base
  belongs_to :club

  has_many :team_sections, dependent: :destroy, inverse_of: :section
  has_many :teams, through: :team_sections, inverse_of: :sections
  has_many :championships, -> { distinct }, through: :teams

  has_many :participations, inverse_of: :section, dependent: :destroy
  has_many :users, -> { distinct }, through: :participations, inverse_of: :sections

  has_many :section_user_invitations, inverse_of: :section, dependent: :destroy
  has_and_belongs_to_many :trainings, inverse_of: :sections

  has_many :groups, inverse_of: :section, dependent: :destroy
  validates_presence_of :club, :name

  def invite_user!(params, inviter)
    raise "Inviter (#{inviter.email}) is not coach of #{self}" unless inviter.coach_of?(self) || inviter.admin_of?(club)

    column_names = SectionUserInvitation.column_names
    column_syms = column_names.map(&:to_sym)
    params_only = params.slice(*column_syms)
    params_only_with_section = params_only.merge(section: self)
    invitation = SectionUserInvitation.create!(params_only_with_section)

    user = User.find_by_email(invitation.email)
    user ||= User.invite!(params_only.delete_if { |k, _v| k.to_s == 'roles' }, inviter)

    add_user! user, params[:roles]
    user
  end

  def add_player!(user, season: nil)
    add_user!(user, Participation::PLAYER, season: season)
  end

  def add_coach!(user, season: nil)
    add_user!(user, Participation::COACH, season: season)
  end

  def members(season: nil)
    season ||= Season.current
    User.joins(:participations).where(participations: { season: season, section: self })
  end

  def players(season: Season.current)
    User.joins(:participations).where(participations: { season: season, role: Participation::PLAYER, section: self })
  end

  def coachs(season: Season.current)
    User.left_joins(:participations).where(participations: { season: season, role: Participation::COACH, section: self })
  end

  def to_param
    "#{id}-#{name}"
  end

  def to_s
    "Section #{name} - #{club.name}"
  end

  def next_trainings
    now = 1.day.ago
    end_date = (now + 2.days).end_of_week + 1.weeks
    trainings.where('start_datetime > ? AND start_datetime < ?', now, end_date)
  end

  def next_matches
    now = DateTime.now.at_beginning_of_week
    end_date = now.at_end_of_week + 2.weeks + 2.days
    Match.join_day.where('COALESCE(start_datetime, days.period_start_date) >= ? AND COALESCE(start_datetime, days.period_start_date) <= ?',
                         now, end_date).date_ordered.where('local_team_id IN (?) OR visitor_team_id IN (?)', teams.map(&:id), teams.map(&:id))
  end

  def group_everybody(season: nil)
    _default_group(:everybody, 'tous les membres', '#226611', season: season)
  end

  def group_every_players(season: nil)
    _default_group(:every_players, 'tous les joueurs', '#28c704', season: season)
  end

  def has_member?(user)
    users.include?(user)
  end

  def remove_member!(user, season: nil)
    season ||= Season.current
    participations.where(user: user, season: season).delete_all
    groups.where(season: season).map { |group| group.remove_user! user, force: true }
  end

  def remove_roles!(user, roles, season: Season.current)
    participations.where(user: user, role: roles, season: season).delete_all
  end

  def copy_from_previous_season
    current_season = Season.current
    previous_season = current_season.previous
    players(season: previous_season).each do |player|
      add_player! player
    end
    coachs(season: previous_season).each do |coach|
      add_coach! coach
    end
    Group.where(season: previous_season, section: self).each(&:copy_to_current_season)
  end

  def next_duties_for(task_key)
    left_join = 'LEFT OUTER JOIN "duty_tasks" ON "duty_tasks"."user_id" = "users"."id" AND "duty_tasks"."key" ='
    users.joins("#{left_join} '#{Arel.sql(task_key.to_s)}'")
         .where('participations.season_id = ?', Season.current.id)
         .select("users.id, users.*, coalesce(max(duty_tasks.realised_at), '1900-01-01') as last_realised_at")
         .group('users.id')
         .order('last_realised_at ASC, authentication_token')
         .limit(3)
  end

  def update_roles!(user, roles = [])
    existing_roles = user.roles_for(self)
    remove_roles!(user, existing_roles - roles)
    add_roles!(user, roles - existing_roles)
  end

  def add_roles!(user, roles, season: Season.current)
    roles.each { |role| add_user!(user, role, season: season) }
  end

  def add_user!(user, role, season: nil)
    raise "unknown role #{role}" unless Participation::ALL_ROLES.include?(role)

    season ||= Season.current
    params = { role: role, user: user, section: self, season: season }
    participations << Participation.create!(params) unless participations.where(params).exists?
    group_everybody(season: season).add_user!(user)
    group_every_players(season: season).add_user!(user) if role == Participation::PLAYER
    self
  end

  protected

  def _default_group(players_role, group_name, color, season: nil)
    season ||= Season.current
    group = groups.where(role: players_role, system: true, season: season).take

    unless group
      group = Group.new(role: players_role, system: true,
                        name: group_name.upcase, description: "#{group_name.capitalize} de la section",
                        color: color, season: season)
      groups << group
    end
    group
  end
end
