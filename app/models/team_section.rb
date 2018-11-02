class TeamSection < ActiveRecord::Base
  belongs_to :team, inverse_of: :team_sections
  belongs_to :section, inverse_of: :team_sections

  validates_presence_of :team, :section
end
