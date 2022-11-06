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

  def get_comite_as_json(code_comite)
    comite = fetch_ffhb_url_as_json("competition/#{code_comite}")
    raise "Could not find comite with id #{code_comite}" if comite['parentName'].blank?

    comite
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

  def build_specific_calendar(json_pool, name, team_links, teams)
    team_links_invert = team_links.invert.select { |id_str, _team| id_str.present? }.transform_keys(&:to_i)
    team_link_ids = team_links_invert.keys
    team_by_names = teams.index_by { |team| team_link_ids.include?(team.id) ? team_links_invert[team.id] : team.name }

    section_team_by_names = team_links.select { |_key, value| value.present? }.transform_values { |v| Team.find(v) }

    calendar = Calendar.new season: Season.current, name: name
    days = []
    matches = []

    I18n.locale = :fr

    json_pool['dates'].each do |index, date|
      period_start_date = Date.parse(date['start'])
      period_end_date = Date.parse(date['finish'])
      day_name = "Journée ##{index} (#{I18n.l(period_start_date, format: :short)} - #{I18n.l(period_end_date, format: :short)})"
      day = Day.new(name: day_name, period_start_date:, period_end_date:)
      days << day

      date['events'].each do |event|
        event_team_names = event['teams'].pluck('name')
        next if event_team_names.intersection(section_team_by_names.keys).blank?

        local_team = team_by_names[event_team_names.first]
        visitor_team = team_by_names[event_team_names.second]
        matches << Match.new(local_team:, visitor_team:, day:)
      end
    end
    calendar.days = days

    [calendar, matches]
  end

  def build_teams(pool_as_json, team_links = {})
    team_links = {} if team_links.blank?

    pool_as_json['teams'].map do |team|
      name = team['name']
      team =
        if team_links[name].present?
          Team.find(team_links[name])
        else
          Team.new name:, club: Club.new(name:)
        end
      EnrolledTeamChampionship.new(team:, enrolled_name: name)
    end
  end

  def build_championship(code_pool:, code_division:, code_comite:, type_competition:, team_links:)
    comite_as_json = get_comite_as_json(code_comite)
    division_as_json = get_division_as_json(code_division)
    pool_as_json = get_pool_as_json(code_pool)

    name = "#{comite_as_json['parentName']} - #{division_as_json['competitionName']}"
    ffhb_key = "#{Season.current.name}-#{type_competition}-#{code_comite}-#{code_division}-#{code_pool}"
    enrolled_team_championships = build_teams(pool_as_json, team_links)
    calendar, matches = build_specific_calendar(pool_as_json, name, team_links, enrolled_team_championships.map(&:team))

    Championship.new(name:, calendar:, ffhb_key:, enrolled_team_championships:, matches:)
  end
end
