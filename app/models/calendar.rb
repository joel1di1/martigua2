class Calendar < ApplicationRecord
  belongs_to :season

  validates_presence_of :season, :name

end
