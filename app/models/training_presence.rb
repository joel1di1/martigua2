class TrainingPresence < ActiveRecord::Base
  belongs_to :user
  belongs_to :training

  validates_presence_of :user, :training
end
