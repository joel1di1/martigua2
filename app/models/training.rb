class Training < ActiveRecord::Base
  belongs_to :location
  has_and_belongs_to_many :sections, inverse_of: :trainings

  has_many :invitations, class: TrainingInvitation
  has_many :training_presences, inverse_of: :training, dependent: :destroy

  validates_presence_of :start_datetime

  scope :of_section, ->(section) { joins(:sections).where("sections.id = ?", section.id) }
  scope :with_start_between, ->(start_period, end_period) { where("start_datetime >= ? AND start_datetime <= ?", start_period, end_period)}


  def send_invitations!
    invitations << TrainingInvitation.new 
  end

  def nb_presents
    training_presences.where(present: true).count
  end

  def nb_not_presents
    training_presences.where(present: false).count
  end

  def nb_presence_not_set
    nb_users = sections.map{|section| section.players.count }.reduce(:+)  
    nb_users - nb_presents - nb_not_presents
  end

  def self.send_presence_mail_for_next_week
    trainings = Training.of_next_week
    return if trainings.empty?
    players = trainings.first.sections.map(&:players).flatten
    players.each do |player|
      Training.delay.send_training_invitation(trainings, player)
    end
  end

  def self.send_training_invitation(trainings, player)
    UserMailer.send_training_invitation(trainings, player).deliver
  end

  def self.of_next_week(date=DateTime.now)
    start_period = date.next_week
    end_period = start_period.end_of_week
    Training.with_start_between(start_period, end_period)
  end

end
