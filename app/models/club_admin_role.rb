class ClubAdminRole < ActiveRecord::Base
  ADMIN = 'admin'.freeze

  belongs_to :club
  belongs_to :user

  validates_presence_of :club, :user, :name
end
