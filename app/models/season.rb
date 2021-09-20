# frozen_string_literal: true

class Season < ActiveRecord::Base
  validates_presence_of :name, :start_date, :end_date

  has_many :participations, inverse_of: :season, dependent: :destroy
  has_many :groups, inverse_of: :season, dependent: :destroy
  has_many :championships, inverse_of: :season, dependent: :destroy
  has_many :calendars, inverse_of: :season, dependent: :destroy

  def self._current
    current = Season.order('end_date DESC').limit(1).first
    current ||= create_default_season
    current = create_next_season(current) while current.end_date < Date.today
    current
  end

  def self.current
    return _current if Rails.env.test? || Rails.env.development?

    Thread.current[:current_season] ||= _current
  end

  def to_s
    "#{start_date.year}-#{end_date.year}"
  end

  def previous
    Season.find(id - 1)
  end

  def self.create_default_season
    Season.create!(start_date: Date.new(2014, 8, 1), end_date: Date.new(2015, 7, 1), name: '2014-2015')
  end

  def self.create_next_season(season)
    Season.create!(start_date: season.start_date + 1.year,
                   end_date: season.end_date + 1.year,
                   name: "#{season.start_date.year + 1}-#{season.end_date.year + 1}")
  end
end
