# frozen_string_literal: true

class ClubAdminRole < ApplicationRecord
  ADMIN = 'admin'

  belongs_to :club
  belongs_to :user

  validates :name, presence: true
end
