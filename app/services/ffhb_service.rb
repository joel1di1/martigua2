# frozen_string_literal: true

require 'singleton'

class FfhbService
  include Singleton

  def get_pool_as_json(code_pool)
    json_pool = fetch_ffhb_url_as_json("pool/#{code_pool}")
    raise "Could not find pool with id #{code_pool}" if json_pool['teams'].blank?

    json_pool
  end

  def get_division_as_json(code_division)
    division = fetch_ffhb_url_as_json("competitionPool/#{code_division}")
    raise "Could not find division with id #{code_division}" if division['competitionName'].blank?

    division
  end

  def fetch_ffhb_url_as_json(path)
    Rails.cache.fetch path, expires_in: 1.day do
      response = fetch_ffhb_url(path)
      Oj.load(response)
    end
  end

  def fetch_ffhb_url(path)
    Net::HTTP.get(URI("https://jjht57whqb.execute-api.us-west-2.amazonaws.com/prod/#{path}"))
  end

  def build_specific_calendar(json_pool, name)
    calendar = Calendar.new season: Season.current, name: name
    calendar.days = json_pool['dates'].map do |index, date|
      Day.new(
        name: "Journée #{index}",
        period_start_date: Date.parse(date['start']),
        period_end_date: Date.parse(date['finish'])
      )
    end
    calendar
  end

  def build_teams(pool_as_json, team_links={})
    team_links = {} if team_links.blank?

    pool_as_json['teams'].map do |team|
      team_name = team['name']
      if team_links[team_name].present?
        Team.find(team_links[team_name])
      else
        Team.new name: team_name, club: Club.new(name: team_name)
      end
    end
  end

  def build_championship(code_pool:, code_division:, code_comite:, type_competition:, team_links:)
    pool_as_json = get_pool_as_json(code_pool)
    division_as_json = get_division_as_json(code_division)

    name = division_as_json['competitionName']
    ffhb_key = "#{Season.current.name}-#{type_competition}-#{code_comite}-#{code_division}-#{code_pool}"
    calendar = build_specific_calendar(pool_as_json, name)
    teams = build_teams(pool_as_json, team_links)

    Championship.new name:, calendar:, ffhb_key:, teams:
  end
end
