class Training < ActiveRecord::Base
  belongs_to :location

  has_and_belongs_to_many :sections, inverse_of: :trainings
  has_and_belongs_to_many :groups, inverse_of: :trainings

  has_many :invitations, class: TrainingInvitation
  has_many :training_presences, inverse_of: :training, dependent: :destroy
  has_many :users, through: :groups 

  validates_presence_of :start_datetime

  scope :of_section, ->(section) { joins(:sections).where("sections.id = ?", section.id) }
  scope :with_start_between, ->(start_period, end_period) { where("start_datetime >= ? AND start_datetime <= ?", start_period, end_period) } 

  default_scope { order 'start_datetime' }

  def send_invitations!
    invitations << TrainingInvitation.new 
  end

  def presents
    training_presences.includes(:user).where(present: true).map(&:user)
  end

  def nb_presents
    presents.count
  end

  def not_presents
    training_presences.includes(:user).where(present: false).map(&:user)
  end
  def nb_not_presents
    not_presents.count
  end

  def nb_presence_not_set
    presence_not_set.size
  end

  def presence_not_set
    users - presents - not_presents
  end

  def group_names
    groups.order('name').map(&:name).join(', ')
  end

  def users
    User.joins(:groups).where(groups: { id: group_ids })
  end

  def self.send_presence_mail_for_next_week
    User.all.each do |user|
      if user.id == 1
        next_week_trainings = user.next_week_trainings
        UserMailer.delay.send_training_invitation(next_week_trainings, user) unless next_week_trainings.empty?
      end
    end
  end

  def self.of_next_week(section=nil, date=DateTime.now)
    start_period = date.next_week
    end_period = start_period.end_of_week
    trainings = Training.with_start_between(start_period, end_period)
    trainings = trainings.of_section(section) unless section.nil?
    trainings
  end
end
