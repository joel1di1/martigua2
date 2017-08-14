class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :club_admin_roles, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :sections, -> { distinct }, through: :participations, inverse_of: :users
  has_many :training_presences, inverse_of: :user, dependent: :destroy

  has_many :match_availabilities, inverse_of: :user, dependent: :destroy

  has_and_belongs_to_many :groups, inverse_of: :users

  validates_presence_of :authentication_token

  before_validation :ensure_authentication_token

  default_scope { order 'first_name' }

  def has_only_one_section?
    sections.count == 1
  end

  def is_coach_of?(section, season=nil)
    is_member_of? section, Participation::COACH, season
  end

  def is_player_of?(section, season=nil)
    is_member_of? section, Participation::PLAYER, season
  end

  def display_participations
    participations.map{ |participation| display_participation participation }.join("\n")
  end

  def display_participation(participation)
    "#{participation.season.to_s} - #{participation.role} of #{participation.section.club.name} - #{participation.section.name}"
  end

  def present_for!(training_or_array, *other_trainings)
    trainings = training_or_array if training_or_array.kind_of? Array
    trainings ||= [training_or_array] + other_trainings
    [*trainings].each{|training| TrainingPresence.create! training: training, user: self, present: true }
  end

  def not_present_for!(training_or_array, *other_trainings)
    trainings = training_or_array if training_or_array.kind_of? Array
    trainings ||= [training_or_array] + other_trainings
    [*trainings].each{|training| TrainingPresence.create! training: training, user: self, present: false }
  end

  def is_present_for?(training)
    training_presences.where(training: training).first.try(:present)
  end

  def is_available_for?(match)
    match_availabilities.where(match: match).first.try(:available)
  end

  def is_admin_of?(club)
    club_admin_roles.where(club: club).exists?
  end

  def full_name
    nickname.blank? ? "#{first_name} #{last_name}" : "#{first_name} #{last_name} - #{nickname}"
  end

  def short_name
    nickname.blank? ? "#{first_name} #{last_name}" : "#{nickname}"
  end

  def next_week_trainings
    Training.of_next_week.joins(:groups).where(groups: {id: group_ids}).distinct
  end

  def next_weekend_matches
    next_matches = Match.of_next_weekend.includes(local_team: :sections, visitor_team: :sections)
    next_matches.select { |match| (match.local_team.sections + match.visitor_team.sections).flatten.select{|s| is_player_of?(s)}.size > 0 }
  end

  protected
    def ensure_authentication_token
      self.authentication_token ||= SecureRandom.urlsafe_base64(32)
    end

    def is_member_of?(section, role, season=nil)
      season ||= Season.current
      participations.where(section: section, role: role, season: season).count > 0
    end
end
