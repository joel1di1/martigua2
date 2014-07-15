class ClubAdminRole < ActiveRecord::Base
  belongs_to :club
  belongs_to :user

  validates_presence_of :club, :user, :name

end
