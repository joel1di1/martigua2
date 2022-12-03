# frozen_string_literal: true

class ChampionshipGroup < ApplicationRecord
  has_many :championship_group_championships, dependent: :destroy
  has_many :championships, through: :championship_group_championships

  def add_championship(championship, index:)
    championship_group_championships.create!(championship:, index:)
  end

  def freeze!(user, championship:)
    championship_index = championship_group_championships.find_by(championship:).index

    championships_to_burn = championship_group_championships.where('index >= ?', championship_index).map(&:championship)

    championships_to_burn.each do |championship_to_burn|
      championship_to_burn.burn!(user)
    end
  end
end
