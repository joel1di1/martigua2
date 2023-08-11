# frozen_string_literal: true

require 'singleton'

class FfhbService
  include Singleton

  def http_get_with_cache(url)
    Rails.cache.fetch url, expires_in: 30.minutes do
      uri = URI(url)
      Net::HTTP.get(uri)
    end
  end

  def fetch_smartfire_attributes(url, attribute_name)
    response = http_get_with_cache(url)
    doc = Nokogiri::HTML(response)
    smartfire_component = doc.at_xpath(attribute_name)
    attributes_content = smartfire_component['attributes']
    attributes_content_decoded = CGI.unescapeHTML(attributes_content)
    Oj.load(attributes_content_decoded)
  end

  def fetch_departemental_details
    attributes = fetch_smartfire_attributes(
      'https://www.ffhandball.fr/competitions/saison-2023-2024-19/departemental/',
      "//smartfire-component[@name='competitions---competition-main-menu']")
  end

  def fetch_comite_details(dep_number)
    comite_hash = list_comites_by_id[dep_number]
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2023-2024-19/departemental/o-#{comite_hash['libelle'].parameterize}-#{comite_hash['ext_structureId']}/",
      "//smartfire-component[@name='competitions---competition-main-menu']"
      )
  end

  def fetch_competition_details(competition_key)
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2023-2024-19/departemental/#{competition_key}/",
      "//smartfire-component[@name='competitions---poule-selector']"
    )
  end

  def fetch_pool_details(competition_key, code_pool)
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2023-2024-19/departemental/#{competition_key}/poule-#{code_pool}/",
      "//smartfire-component[@name='competitions---poule-selector']"
    )
  end

  def fetch_journee_details(competition_key, code_pool, journee_number)
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2023-2024-19/departemental/#{competition_key}/poule-#{code_pool}/journee-#{journee_number}/",
      "//smartfire-component[@name='competitions---rencontre-list']"
    )
  end

  def list_teams_for_pool(competition_key, code_pool)
    attributes = fetch_pool_details(competition_key, code_pool)
    attributes['equipe_options']
  end

  def list_comites_by_id
    attributes = fetch_departemental_details
    attributes['structures'].index_by { |structure| structure['oldUrl'][1..].to_i }
  end

  def list_competitions(dep_number)
    attributes = fetch_comite_details(dep_number)
    attributes['competitions']
  end

  def build_specific_calendar(pool_details, name, team_links, teams, linked_calendar = nil)
    team_links_invert = team_links.invert.select { |id_str, _team| id_str.present? }.transform_keys(&:to_i)
    team_link_ids = team_links_invert.keys
    team_by_names = teams.index_by { |team| team_link_ids.include?(team.id) ? team_links_invert[team.id] : team.name }

    section_team_by_names = team_links.select { |_key, value| value.present? }.transform_values { |v| Team.find(v) }

    calendar = linked_calendar || Calendar.new(season: Season.current, name:)
    matches = []

    I18n.locale = :fr

    journees = Oj.load(pool_details['selected_poule']['journees'])

    journees.each do |journee|
      period_start_date = Date.parse(journee['date_debut'])
      period_end_date = Date.parse(journee['date_fin'])
      day_name = "WE du #{I18n.l(period_start_date, format: :short)} au #{I18n.l(period_end_date, format: :short)}"

      day = find_or_create_day(calendar, linked_calendar, day_name, period_start_date, period_end_date)

      journee_details = fetch_journee_details(pool_details['url_competition'], pool_details['ext_poule_id'], journee['journee_numero'])
      journee_details['rencontres'].each do |match|

      end
    end

    [calendar, matches]
  end

  def find_or_create_day(calendar, linked_calendar, day_name, period_start_date, period_end_date)
    day = linked_calendar.days.find_by(name: day_name) if linked_calendar.present?
    if day.blank?
      day = Day.new(name: day_name, period_start_date:, period_end_date:)
      calendar.days << day
    end
    day
  end

  def build_teams(pool_details, team_links = {})
    team_links = {} if team_links.blank?

    pool_details['equipe_options'].map do |team|
      name = team['libelle']
      equipe_id = team['ext_equipeId']
      team =
        if team_links[equipe_id].present?
          Team.find(team_links[equipe_id])
        else
          Team.new name:, club: Club.new(name:)
        end
      EnrolledTeamChampionship.new(team:, enrolled_name: name)
    end
  end

  def build_championship(type_competition:, code_comite:, code_competition:, phase_id:, code_pool:, team_links:, linked_calendar: nil)
    comite_details = fetch_comite_details(code_comite.to_i)
    pool_details = fetch_pool_details(code_competition, code_pool)

    comite_name = comite_details['structure']['libelle']
    competition_name = comite_details['competitions'].find {|c| c['ext_competitionId'] == code_competition[/(\d+)$/]}['libelle']
    name = "#{comite_name} - #{competition_name}"

    saison = "#{comite_details['saison']['libelle'].gsub(/\s+/, '')}-#{comite_details['saison']['ext_saisonId']}"
    ffhb_key = "#{saison} #{comite_details['url_competition_type']} #{pool_details['url_competition']} #{pool_details['selected_poule']['phaseId']} #{pool_details['selected_poule']['ext_pouleId']}"

    enrolled_team_championships = build_teams(pool_details, team_links)
    calendar, matches = build_specific_calendar(pool_details, name, team_links, enrolled_team_championships.map(&:team), linked_calendar)

    Championship.new(name:, calendar:, ffhb_key:, enrolled_team_championships:, matches:)
  end
end
