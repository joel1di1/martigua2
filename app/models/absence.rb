# frozen_string_literal: true

class Absence < ApplicationRecord
  MOTIVES = %w[Blessure Maladie Perso Travail Autre].freeze

  validates :name, presence: true, inclusion: { in: MOTIVES }
  validates :start_at, presence: true
  validates :end_at, presence: true

  after_save :update_training_presences
  after_save :update_match_availabilities

  belongs_to :user

  def update_training_presences
    # all training that start between start_at and end_at
    trainings = Training.with_start_between(start_at, end_at)
    user.not_present_for!(trainings)
  end

  def update_match_availabilities
    user_teams = Team.joins(:sections).where(sections: user.sections)
    section_matchs = Match.where(local_team: user_teams).or(Match.where(visitor_team: user_teams))
    matchs = section_matchs.with_start_between(start_at, end_at)
    other_matchs = section_matchs.where(start_datetime: nil).includes(:day).where(day: { period_start_date: start_at..end_at, period_end_date: start_at..end_at })

    user.not_available_for!(matchs + other_matchs)
  end
end
