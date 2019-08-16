# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :club_admin_roles, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :sections, -> { distinct }, through: :participations, inverse_of: :users
  has_many :training_presences, inverse_of: :user, dependent: :destroy
  has_many :duty_tasks, inverse_of: :user, dependent: :destroy
  has_many :match_availabilities, inverse_of: :user, dependent: :destroy

  has_and_belongs_to_many :groups, inverse_of: :users

  validates_presence_of :authentication_token

  before_validation :ensure_authentication_token
  before_save :format_phone_number

  scope :active_this_season, -> { includes(:participations).where(participations: { season: Season.current }) }

  def has_only_one_section?
    sections.count == 1
  end

  def is_coach_of?(section, season: nil)
    is_member_of? section, Participation::COACH, season: season
  end

  def is_player_of?(section, season: nil)
    is_member_of? section, Participation::PLAYER, season: season
  end

  def display_participations
    participations.map { |participation| display_participation participation }.join("\n")
  end

  def display_participation(participation)
    "#{participation.season} - #{participation.role} of #{participation.section.club.name} - #{participation.section.name}"
  end

  def present_for!(training_or_array, *other_trainings)
    _set_presence_for!(true, training_or_array, *other_trainings)
  end

  def not_present_for!(training_or_array, *other_trainings)
    _set_presence_for!(false, training_or_array, *other_trainings)
  end

  def _set_presence_for!(present, training_or_array, *other_trainings)
    trainings = training_or_array if training_or_array.is_a? Array
    trainings ||= [training_or_array] + other_trainings

    presences = {}
    training_presences.each { |training_presence| presences[training_presence.training_id] = training_presence }

    [*trainings].each do |training|
      presence = presences[training.id]
      if presence.nil?
        training_presences << TrainingPresence.new(training: training, user: self, present: present)
      else
        presence.update present: present
      end
    end
  end

  def is_present_for?(training)
    training_presences.where(training: training).first.try(:present)
  end

  def is_available_for?(match)
    match_availabilities.select { |ma| ma.match_id == match.id }.first.try(:available)
  end

  def has_respond_for?(match)
    match_availabilities.select { |ma| ma.match_id == match.id }.size > 0
  end

  def is_admin_of?(club)
    club_admin_roles.where(club: club).exists?
  end

  def full_name
    nickname.blank? ? "#{first_name} #{last_name}" : "#{first_name} #{last_name} - #{nickname}"
  end

  def to_s
    full_name
  end

  def short_name
    nickname.blank? ? "#{first_name} #{last_name}" : "#{nickname}"
  end

  def next_week_trainings
    Training.of_next_week.joins(:groups).where(groups: { id: group_ids }).distinct
  end

  def next_weekend_matches
    next_matches = Match.of_next_weekend.includes(local_team: :sections, visitor_team: :sections)
    next_matches.select { |match| (match.local_team.sections + match.visitor_team.sections).flatten.select { |s| is_player_of?(s) }.size > 0 }
  end

  def realised_task!(task_name, realised_at)
    duty_tasks << DutyTask.create(name: task_name, realised_at: realised_at)
  end

  def last_time_duty(task_name)
    duty_tasks.where(name: task_name).order('name DESC').first&.realised_at
  end

  def was_present?(training)
    training_presence = training_presences.where(training: training).first
    return unless training_presence
    training_presence.presence_validated? || (training_presence.present? && training_presence.presence_validated.nil?)
  end

  def confirm_presence!(training)
    _confirm_presence!(training, true)
  end

  def confirm_no_presence!(training)
    _confirm_presence!(training, false)
  end

  def _confirm_presence!(training, presence)
    training_presence = training_presences.find_or_create_by(training: training)
    training_presence.update!(presence_validated: presence)
  end

  protected

  def ensure_authentication_token
    self.authentication_token ||= SecureRandom.urlsafe_base64(32)
  end

  def is_member_of?(section, role, season: nil)
    season ||= Season.current
    @membership_cache ||= {}
    @membership_cache[{ section: section, role: role, season: season }] ||= participations.where(section: section, role: role, season: season).size > 0
  end

  def format_phone_number
    if phone_number && phone_number.match('^[\s\d]*$')
      self.phone_number = phone_number.gsub(' ', '').gsub(/(\d\d)/, '\1 ').chop
    end
  end
end
