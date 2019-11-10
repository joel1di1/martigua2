# frozen_string_literal: true

class Team < ActiveRecord::Base
  belongs_to :club

  has_many :team_sections, dependent: :destroy, inverse_of: :team
  has_many :sections, through: :team_sections, inverse_of: :teams

  has_many :enrolled_team_championships
  has_many :championships, through: :enrolled_team_championships

  validates_presence_of :club
  validates_presence_of :name

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
end
