# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include Attendance
  include Availability

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fit: [32, 32]
    attachable.variant :portrait, resize_to_limit: [300, 300]
  end

  has_many :burns, dependent: :destroy
  has_many :club_admin_roles, dependent: :destroy
  has_many :contact_emails, class_name: 'UserContactEmail', inverse_of: :user, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :selections, dependent: :destroy
  has_many :match_selections, dependent: :destroy
  has_many :match_invitations, dependent: :nullify
  has_many :sections, -> { distinct }, through: :participations, inverse_of: :users
  has_many :duty_tasks, inverse_of: :user, dependent: :destroy
  has_many :user_championship_stats, inverse_of: :user, dependent: :destroy
  has_many :player_match_stats, dependent: :destroy
  has_many :webpush_subscriptions, inverse_of: :user, dependent: :destroy
  has_many :user_channel_messages, inverse_of: :user, dependent: :destroy

  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  validates :authentication_token, presence: true

  before_validation :ensure_authentication_token

  generates_token_for :email_authentication, expires_in: 30.days do
    authentication_token
  end

  # Data minimisation (RGPD): Devise trackable keeps sign-in dates and counts, never IPs.
  def extract_ip_from(_request) = nil

  scope :active_this_season, -> { includes(:participations).where(participations: { season: Season.current }) }

  ANONYMIZED_EMAIL_DOMAIN = 'anonymized.invalid'

  # RGPD retention: no section membership, sign-in nor account creation since `cutoff`.
  scope :inactive_since, lambda { |cutoff|
    where(super_admin: false, created_at: [nil, ...cutoff], current_sign_in_at: [nil, ...cutoff])
      .where.not(id: Participation.joins(:season).where(seasons: { end_date: cutoff.. }).select(:user_id))
      .where.not('email LIKE ?', "%@#{ANONYMIZED_EMAIL_DOMAIN}")
  }

  def self.anonymize_inactive!
    inactive_since(3.years.ago).find_each(&:anonymize!)
  end

  # Keeps the sports history (participations, presences, selections, stats) under an anonymous
  # name; drops what identifies the person or a third party.
  def anonymize!
    transaction do
      [absences, contact_emails, webpush_subscriptions, club_admin_roles].each(&:destroy_all)
      player_match_stats.update_all(first_name: nil, last_name: nil) # rubocop:disable Rails/SkipsModelValidations
      user_championship_stats.update_all(first_name: nil, last_name: nil) # rubocop:disable Rails/SkipsModelValidations
      update!(first_name: 'Ancien', last_name: "Membre #{id}", nickname: nil, phone_number: nil,
              email: "anonyme-#{id}@#{ANONYMIZED_EMAIL_DOMAIN}", password: SecureRandom.hex(32),
              authentication_token: SecureRandom.urlsafe_base64(32), invitation_token: nil, reset_password_token: nil)
    end
    avatar.purge
  end

  # Relatives copied on everything this user receives.
  def contact_email_addresses
    contact_emails.map(&:email)
  end

  def has_only_one_section?
    sections.one?
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

  # Label used by the switch_user impersonation widget (see config/initializers/switch_user.rb).
  # SwitchUser::DataSource::Record#label calls `user.send(name)`, so this has to be a real method.
  # first_name / last_name are nullable, and full_name would raise on them: fall back to the email.
  def full_name_with_email
    return email if first_name.blank? || last_name.blank?

    "#{full_name} (#{email})"
  end

  def short_name
    nickname.presence || "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def read?(message)
    user_channel_messages.exists?(message:, read: true)
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
    @membership_cache[{ section:, role:, season: }] ||= participations.where(section:, role:, season:).any?
  end
end
