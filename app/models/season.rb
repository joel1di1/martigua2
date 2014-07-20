class Season < ActiveRecord::Base
  validates_presence_of :name, :start_date, :end_date 

  has_many :participations, inverse_of: :season

  def self.current
    Season.last || Season.create!(start_date: Date.new(2014, 9, 1), end_date: Date.new(2015, 7, 1), name: '2014-2015')
  end

  def to_s
    "#{start_date.year}-#{end_date.year}"
  end

end
