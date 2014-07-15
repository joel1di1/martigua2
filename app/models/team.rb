class Team < ActiveRecord::Base
  belongs_to :club

  validates_presence_of :club
  validates_presence_of :name
end
