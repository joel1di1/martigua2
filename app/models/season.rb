# frozen_string_literal: true

class Season < ApplicationRecord
  validates :name, :start_date, :end_date, presence: true

  has_many :participations, inverse_of: :season, dependent: :destroy
  has_many :groups, inverse_of: :season, dependent: :destroy
  has_many :championships, inverse_of: :season, dependent: :destroy
  has_many :calendars, inverse_of: :season, dependent: :destroy

  after_commit :renew_coaches_from_previous_season, on: :create

  def self._current
    current = Season.order(end_date: :desc).limit(1).first
    current ||= create_default_season
    current = create_next_season(current) while current.end_date < Time.zone.today
    current
  end

  def self.current
    return _current if Rails.env.local?

    Thread.current[:current_season] ||= _current
  end

  def to_s
    "#{start_date.year}-#{end_date.year}"
  end

  def previous
    Season.where(id: ...id).order(id: :desc).first
  end

  def self.create_default_season
    Season.create!(start_date: Date.new(2014, 8, 1), end_date: Date.new(2015, 7, 31), name: '2014-2015')
  end

  def self.create_next_season(season)
    Season.create!(start_date: season.start_date + 1.year,
                   end_date: season.end_date + 1.year,
                   name: "#{season.start_date.year + 1}-#{season.end_date.year + 1}")
  end

  private

  def renew_coaches_from_previous_season
    prev_season = previous
    return unless prev_season

    # Get all participations from the previous season
    previous_participations = Participation.where(season: prev_season)

    # Group participations by user and section to handle users with multiple roles
    previous_participations.group_by { |p| [p.user, p.section] }.each do |(user, section), participations|
      roles = participations.map(&:role).uniq

      # Renew each role the user had in the previous season
      # Coaches are automatically renewed, and players who are also coaches are renewed too
      roles.each do |role|
        if role == Participation::COACH
          section.add_coach!(user, season: self)
        elsif role == Participation::PLAYER
          # Only renew players if they were also coaches
          section.add_player!(user, season: self) if roles.include?(Participation::COACH)
        end
      end
    end
  end
end
