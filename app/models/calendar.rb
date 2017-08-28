class Calendar < ApplicationRecord
  belongs_to :season
  has_many :days, inverse_of: :calendar

  validates_presence_of :season, :name

end
