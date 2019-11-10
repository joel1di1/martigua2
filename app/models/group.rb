# frozen_string_literal: true

class Group < ActiveRecord::Base
  belongs_to :section
  belongs_to :season

  has_and_belongs_to_many :users, inverse_of: :groups
  has_and_belongs_to_many :trainings, inverse_of: :groups

  validates_presence_of :name, :season, :section

  scope :non_system, -> { where(system: false) }

  def add_user!(user)
    users << user unless users.include?(user)
    self
  end

  def remove_user!(user, force: false)
    raise 'You cannot remove user from system group' if system? && !force

    users.delete(user)
  end

  def copy_to_current_season
    Group.create!(section: section, season: Season.current,
                  name: name, system: system, users: users,
                  color: color, description: description, role: role)
  end
end
