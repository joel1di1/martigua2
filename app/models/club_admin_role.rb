class ClubAdminRole < ActiveRecord::Base

  ADMIN='admin'

  belongs_to :club
  belongs_to :user

  validates_presence_of :club, :user, :name

end
