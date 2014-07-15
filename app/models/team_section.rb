class TeamSection < ActiveRecord::Base
  belongs_to :team
  belongs_to :section

  validates_presence_of :team, :section

end
