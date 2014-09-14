class Match < ActiveRecord::Base
  belongs_to :championship
  belongs_to :location
end
