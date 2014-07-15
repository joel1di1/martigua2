class Section < ActiveRecord::Base
  belongs_to :club

  has_many :team_sections
  has_many :teams, through: :team_sections 

  validates_presence_of :club, :name

end
