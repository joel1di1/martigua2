# frozen_string_literal: true

class Absence < ApplicationRecord
  MOTIVES = %w[Blessure Maladie Perso Travail Autre].freeze

  validates :name, presence: true, inclusion: { in: MOTIVES }

  after_save :update_training_presences
  after_save :update_match_availabilities

  belongs_to :user

  def update_training_presences
    # all training that start between start_at and end_at
    trainings = Training.with_start_between(start_at, end_at)
    user.not_present_for!(trainings)
  end

  def update_match_availabilities
    matchs = Match.with_start_between(start_at, end_at)
    user.not_available_for!(matchs)
  end
end
