class Season < ActiveRecord::Base
  has_many :days, inverse_of: :season, dependent: :destroy
  has_many :championships, inverse_of: :season, dependent: :destroy
  has_many :calendars, inverse_of: :season, dependent: :destroy
end

class Day < ActiveRecord::Base
  belongs_to :calendar
  belongs_to :season
end

class MoveAllPreviousDaysToDefaultCalendar < ActiveRecord::Migration[5.1]
  DEFAULT_NAME = "*DEFAULT_CALENDAR_FOR_MIGRATION*"

  def up
    Season.all.each do |season|
      if season.calendars.count == 0
        calendar = Calendar.create! season: season, name: DEFAULT_NAME
        season.championships.update_all(calendar_id: calendar.id)
        season.days.update_all(calendar_id: calendar.id)
      end
    end
  end
  def down
    calendars = Calendar.where(name: DEFAULT_NAME)
    calendars.each do |calendar|
      calendar.days.update_all(season_id: calendar.season_id)
    end
  end
end
