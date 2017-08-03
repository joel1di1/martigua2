class Season < ActiveRecord::Base
  validates_presence_of :name, :start_date, :end_date

  has_many :participations, inverse_of: :season, dependent: :destroy
  has_many :groups, inverse_of: :season, dependent: :destroy
  has_many :days, inverse_of: :season, dependent: :destroy

  after_create :create_default_days!

  def self.current
    current = Season.order('end_date DESC').limit(1).first
    current ||= Season.create!(start_date: Date.new(2014, 8, 1), end_date: Date.new(2015, 7, 1), name: '2014-2015')
    while current.end_date < Date.today
      current = Season.create!(start_date: current.start_date + 1.year, end_date: current.end_date + 1.year, name: "#{current.start_date.year + 1}-#{current.end_date.year + 1}")
    end
    current
  end

  def to_s
    "#{start_date.year}-#{end_date.year}"
  end

  def create_default_days!
    default_days = []
    d = start_date

    while !d.saturday? do
      d = d + 1.day
    end

    while d < end_date do
      day = Day.new(period_start_date: d, period_end_date: (d+1.day), season: self )
      day.name = "#{day.period_start_date.to_s(:short)} - #{day.period_end_date.to_s(:short)}"
      day.save!
      default_days << day
      d = d + 1.week
    end
    d = default_days
  end

end
