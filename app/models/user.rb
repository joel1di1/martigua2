class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :club_admin_roles
  has_many :participations
  has_many :sections, through: :participations, inverse_of: :users

  validates_presence_of :authentication_token

  before_validation :ensure_authentication_token

  def has_only_one_section?
    sections.count == 1
  end

  def coach_of?(section)
    participations.where(section: section, role: Participation::COACH).count > 0
  end

  protected 
    def ensure_authentication_token
      self.authentication_token ||= SecureRandom.urlsafe_base64(32)
    end    
end
