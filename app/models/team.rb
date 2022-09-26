# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :club

  has_many :team_sections, dependent: :destroy, inverse_of: :team
  has_many :sections, through: :team_sections, inverse_of: :teams

  has_many :enrolled_team_championships, dependent: :destroy
  has_many :championships, through: :enrolled_team_championships

  validates :name, presence: true

  def self.team_with_match_on(day, section)
    section_teams = section.teams
    day_teams = day.matches.includes(:local_team, :visitor_team, :location).map(&:teams).flatten
    teams = section_teams & day_teams
    teams.map do |team|
      match = nil
      day.matches.each do |m|
        match = m if m.teams.include? team
      end
      [team, match]
    end
  end

  def full_name
    "#{name} - \[#{club.name}\]"
  end
end
