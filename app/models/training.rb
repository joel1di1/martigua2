class Training < ActiveRecord::Base
  belongs_to :location
  has_and_belongs_to_many :sections, inverse_of: :trainings

  has_many :invitations, class: TrainingInvitation
  has_many :training_presences, inverse_of: :training

  validates_presence_of :start_datetime

  scope :of_section, ->(section) { joins(:sections).where("sections.id = ?", section.id) }

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
end
