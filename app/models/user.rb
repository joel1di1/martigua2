class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :club_admin_roles, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :sections, through: :participations, inverse_of: :users

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

  protected 
    def ensure_authentication_token
      self.authentication_token ||= SecureRandom.urlsafe_base64(32)
    end    

    def is_member_of?(section, role)
      participations.where(section: section, role: role).count > 0
    end
end
