class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :club_admin_roles, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :sections, through: :participations, inverse_of: :users
  has_many :training_availabilities, inverse_of: :user

  validates_presence_of :authentication_token

  before_validation :ensure_authentication_token

  def has_only_one_section?
    sections.count == 1
  end

  def is_coach_of?(section)
    is_member_of? section, Participation::COACH
  end

  def is_player_of?(section)
    is_member_of? section, Participation::PLAYER
  end

  def display_participations
    participations.map{ |participation| display_participation participation }.join("\n")
  end

  def display_participation(participation)
    "#{participation.season.to_s} - #{participation.role} of #{participation.section.club.name} - #{participation.section.name}"
  end

  def available_for!(training_or_array, *other_trainings)
    trainings = training_or_array if training_or_array.kind_of? Array
    trainings ||= [training_or_array] + other_trainings
    [*trainings].each{|training| TrainingAvailability.create! training: training, user: self }
  end

  def is_available_for?(training)
    true
  end

  protected 
    def ensure_authentication_token
      self.authentication_token ||= SecureRandom.urlsafe_base64(32)
    end    

    def is_member_of?(section, role)
      participations.where(section: section, role: role).count > 0
    end
end
