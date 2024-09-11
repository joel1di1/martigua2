# frozen_string_literal: true

class User < ApplicationRecord # rubocop:disable Metrics/ClassLength
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fit: [32, 32]
    attachable.variant :portrait, resize_to_limit: [300, 300]
  end

  has_many :burns, dependent: :destroy
  has_many :club_admin_roles, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :sections, -> { distinct }, through: :participations, inverse_of: :users
  has_many :training_presences, inverse_of: :user, dependent: :destroy
  has_many :duty_tasks, inverse_of: :user, dependent: :destroy
  has_many :match_availabilities, inverse_of: :user, dependent: :destroy
  has_many :user_championship_stats, inverse_of: :user, dependent: :destroy
  has_many :webpush_subscriptions, inverse_of: :user, dependent: :destroy
  has_many :user_channel_messages, inverse_of: :user, dependent: :destroy
  has_many :absences, inverse_of: :user, dependent: :destroy

  has_and_belongs_to_many :groups, inverse_of: :users

  validates :authentication_token, presence: true

  before_validation :ensure_authentication_token

  scope :active_this_season, -> { includes(:participations).where(participations: { season: Season.current }) }

  def has_only_one_section?
    sections.count == 1
  end

  def member_of?(section, season: nil)
    is_member_of?(section, [Participation::COACH, Participation::PLAYER], season:)
  end

  def coach_of?(section, season: nil)
    is_member_of?(section, Participation::COACH, season:)
  end

  def player_of?(section, season: nil)
    is_member_of? section, Participation::PLAYER, season:
  end

  def roles_for(section, season: Season.current)
    participations.where(section:, season:).map(&:role)
  end

  def display_participations
    participations.map { |participation| display_participation participation }.join("\n")
  end

  def display_participation(participation)
    "#{participation.season} - #{participation.role} of #{participation.section.club.name} - #{participation.section.name}"
  end

  def present_for!(training_or_array, *)
    _set_presence_for!(true, training_or_array, *)
  end

  def not_present_for!(training_or_array, *)
    _set_presence_for!(false, training_or_array, *)
  end

  def _set_presence_for!(present, training_or_array, *other_trainings)
    trainings = training_or_array if training_or_array.is_a? Array
    trainings ||= [training_or_array] + other_trainings

    presences = {}
    training_presences.each { |training_presence| presences[training_presence.training_id] = training_presence }

    [*trainings].each do |training|
      presence = presences[training.id]
      if presence.nil?
        training_presences << TrainingPresence.new(training:, user: self, is_present: present)
      else
        presence.update is_present: present
      end
    end
  end

  def present_for?(training)
    training_presences.where(training:).first.try(:is_present)
  end

  def set_present_for?(training)
    training_presences.where(training:).first.is_present != nil
  end

  def is_available_for?(match)
    match_availabilities.find { |ma| ma.match_id == match.id }.try(:available)
  end

  def admin_of?(club)
    return false if club.nil?

    club_admin_roles.exists?(club:)
  end

  def full_name
    nickname.blank? ? "#{first_name.capitalize} #{last_name.capitalize}" : "#{first_name.capitalize} #{last_name.capitalize} - #{nickname}"
  end

  def to_s
    full_name
  end

  def short_name
    nickname.presence || "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def next_week_trainings(date: DateTime.now)
    start_date = date.next_week
    end_date = start_date + 1.week
    # retrieve all days where the user is absent
    current_absences = absences.where(start_at: date..(date.next_week)).or(absences.where(end_at: date..(date.next_week)))
    days_to_check = (start_date..end_date).to_a.map(&:to_date)
    days_to_check.reject! { |d| current_absences.any? { |a| a.start_at <= d && a.end_at >= d } }

    Training.with_start_on(days_to_check)
            .includes(:groups)
            .where(groups: { id: group_ids })
  end

  def next_7_days_matches
    start_date = Time.zone.now.to_date
    end_date = start_date + 7.days

    # remove days where user is absent
    current_absences = absences.where(start_at: start_date..end_date).or(absences.where(end_at: start_date..end_date))
    days_to_check = (start_date..end_date).to_a.map(&:to_date)
    days_to_check.reject! { |d| current_absences.any? { |a| a.start_at <= d && a.end_at >= d } }

    next_matches = Match.on_days(days_to_check)
                        .includes(local_team: :sections, visitor_team: :sections)
    next_matches.reject do |match|
      (match.local_team.sections + match.visitor_team.sections).flatten.none? do |s|
        player_of?(s)
      end
    end
  end

  def realised_task!(task_key, realised_at, club)
    duty_tasks << DutyTask.create!(key: task_key, realised_at:, user: self, club:)
  end

  def last_time_duty(task_key)
    duty_tasks.where(name: task_key).order('name DESC').first&.realised_at
  end

  def was_present?(training, presences_by_user_and_training = nil)
    training_presence = if presences_by_user_and_training.present?
                          presences_by_user_and_training[[id, training.id]]
                        else
                          training_presences.where(training:).first
                        end
    return false unless training_presence

    training_presence.presence_validated? || (training_presence.is_present? && training_presence.presence_validated.nil?)
  end

  def confirm_presence!(training)
    _confirm_presence!(training, true)
  end

  def confirm_no_presence!(training)
    _confirm_presence!(training, false)
  end

  def _confirm_presence!(training, presence)
    training_presence = training_presences.find_or_create_by(training:)
    training_presence.update!(presence_validated: presence)
  end

  def super_admin?
    id == 1
  end

  def read?(message)
    user_channel_messages.find_or_create_by(message:, channel: message.channel).read?
  end

  def read!(message_ids)
    message_ids = [*message_ids]
    message_ids.each do |message_id|
      message = Message.find(message_id)
      user_channel_messages.find_or_create_by(message:, channel: message.channel).update!(read: true)
    end
  end

  protected

  def ensure_authentication_token
    self.authentication_token ||= SecureRandom.urlsafe_base64(32)
  end

  def is_member_of?(section, role, season: nil)
    season ||= Season.current
    @membership_cache ||= {}
    @membership_cache[{ section:, role:, season: }] ||= participations.where(section:, role:, season:).count.positive?
  end
end
