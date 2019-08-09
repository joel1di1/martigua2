# frozen_string_literal: true

class ClubAdminRole < ActiveRecord::Base
  ADMIN = 'admin'

  belongs_to :club
  belongs_to :user

  validates_presence_of :club, :user, :name
end
