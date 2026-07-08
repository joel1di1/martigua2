# frozen_string_literal: true

class Absence < ApplicationRecord
  MOTIVES = %w[Blessure Maladie Perso Travail Autre].freeze

  validates :name, presence: true, inclusion: { in: MOTIVES }
  validates :start_at, presence: true
  validates :end_at, presence: true

  after_save :update_training_presences
  after_save :update_match_availabilities

  belongs_to :user

  # Absences that span the whole period. start_at/end_at are date columns, so the
  # comparison is date-granular: being absent through the day a match takes place
  # counts as covering it, whatever the kick-off time.
  scope :covering, lambda { |start_time, end_time|
    where(start_at: ..start_time.to_date).where(end_at: end_time.to_date..)
  }

  def covers?(start_time, end_time)
    start_at <= start_time.to_date && end_at >= end_time.to_date
  end

  def update_training_presences
    # all training that start between start_at and end_at
    trainings = Training.with_start_between(start_at, end_at)
    user.not_present_for!(trainings)
  end

  def update_match_availabilities
    user_teams = Team.joins(:sections).where(sections: user.sections)
    section_matchs = Match.where(local_team: user_teams).or(Match.where(visitor_team: user_teams))
    matchs = section_matchs.with_start_between(start_at, end_at)
    other_matchs = section_matchs.where(start_datetime: nil).includes(:day).where(day: {
                                                                                    period_start_date: start_at..end_at, period_end_date: start_at..end_at
                                                                                  })

    user.not_available_for!(matchs + other_matchs)
  end
end
