# frozen_string_literal: true

class Club < ActiveRecord::Base
  validates_presence_of :name

  has_many :sections, inverse_of: :club, dependent: :destroy

  has_many :club_admin_roles
  has_many :admins, :through => :club_admin_roles, :source => :user

  def add_admin!(user)
    ClubAdminRole.create! club: self, user: user, name: ClubAdminRole::ADMIN unless user.is_admin_of?(self)
  end

  def to_s
    name
  end

  def to_param
    "#{id}-#{name}"
  end
end
