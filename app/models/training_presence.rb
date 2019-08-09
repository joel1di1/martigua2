# frozen_string_literal: true

class TrainingPresence < ActiveRecord::Base
  belongs_to :user
  belongs_to :training, inverse_of: :training_presences

  validates_presence_of :user, :training
end
