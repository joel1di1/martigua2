class Selection < ActiveRecord::Base
  belongs_to :user
  belongs_to :match
  belongs_to :team

  validates_presence_of :user, :team, :match
end
