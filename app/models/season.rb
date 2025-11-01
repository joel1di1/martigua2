# frozen_string_literal: true

class Season < ApplicationRecord
  validates :name, :start_date, :end_date, presence: true

  has_many :participations, inverse_of: :season, dependent: :destroy
  has_many :groups, inverse_of: :season, dependent: :destroy
  has_many :championships, inverse_of: :season, dependent: :destroy
  has_many :calendars, inverse_of: :season, dependent: :destroy

  after_create :renew_coaches_from_previous_season

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

    # Get all coach participations from the previous season
    coach_participations = Participation.where(season: prev_season, role: Participation::COACH)

    # Create new participations for coaches in the new season
    coach_participations.find_each do |participation|
      Participation.create!(
        user: participation.user,
        section: participation.section,
        role: Participation::COACH,
        season: self
      )
    end
  end
end
