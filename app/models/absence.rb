# frozen_string_literal: true

class Absence < ApplicationRecord
  MOTIVES = %w[Blessure Maladie Perso Travail Autre].freeze

  validates :name, presence: true, inclusion: { in: MOTIVES }

  after_save :update_training_presences
  after_save :update_match_availabilities

  belongs_to :user

  def update_training_presences
    TrainingPresence.where(user:)
                    .where(training: Training.with_start_between(start_at, end_at)).update_all(is_present: false) # rubocop:disable Rails/SkipsModelValidations
  end

  def update_match_availabilities
    MatchAvailability.where(user:)
                     .where(match: Match.with_start_between(start_at, end_at)).update_all(available: false) # rubocop:disable Rails/SkipsModelValidations
  end
end
