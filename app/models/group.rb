# frozen_string_literal: true

class Group < ApplicationRecord
  belongs_to :section
  belongs_to :season

  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
  has_and_belongs_to_many :trainings, inverse_of: :groups

  validates :name, presence: true

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
    Group.create!(section:, season: Season.current,
                  name:, system:, users:,
                  color:, description:, role:)
  end
end
