# frozen_string_literal: true

class User < ApplicationRecord
  # Match availability and absences.
  module Availability
    extend ActiveSupport::Concern

    included do
      has_many :match_availabilities, inverse_of: :user, dependent: :destroy
      has_many :absences, inverse_of: :user, dependent: :destroy
    end

    def available_for?(match)
      match_availabilities.find { |ma| ma.match_id == match.id }.try(:available)
    end

    def absent_for?(match)
      absences.any? { |absence| absence.covers?(match.calculated_start_datetime, match.calculated_end_datetime) }
    end

    def not_available_for!(match_or_collection)
      Array.wrap(match_or_collection).each do |match|
        match_availability = MatchAvailability.find_or_create_by(user: self, match:)
        match_availability.update!(available: false)
      end
    end

    def next_7_days_matches
      start_date = Time.zone.now.to_date
      end_date = start_date + 7.days

      # remove days where user is absent
      current_absences = absences.where(start_at: start_date..end_date).or(absences.where(end_at: start_date..end_date))
      days_to_check = (start_date..end_date).to_a.map(&:to_date)
      days_to_check.reject! { |d| current_absences.any? { |a| d.between?(a.start_at, a.end_at) } }

      next_matches = Match.on_days(days_to_check)
                          .includes(local_team: :sections, visitor_team: :sections)
      next_matches.reject do |match|
        (match.local_team.sections + match.visitor_team.sections).flatten.none? do |s|
          player_of?(s)
        end
      end
    end
  end
end
