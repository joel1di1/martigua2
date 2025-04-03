# frozen_string_literal: true

require 'singleton'

class FfhbService # rubocop:disable Metrics/ClassLength
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
    smartfire_component = doc.at_xpath("//smartfire-component[@name='#{attribute_name}']")
    attributes_content = smartfire_component['attributes']
    attributes_content_decoded = CGI.unescapeHTML(attributes_content)
    Oj.load(attributes_content_decoded)
  rescue StandardError => e
    raise FfhbServiceError, e.message
  end

  def save_results_in_file(filename, json_content)
    Rails.root.join('spec/fixtures/ffhb/2023', filename).write(json_content.to_json)
  end

  def fetch_departemental_details
    fetch_smartfire_attributes(
      'https://www.ffhandball.fr/competitions/saison-2024-2025-20/departemental/',
      'competitions---competition-main-menu'
    )
  end

  def fetch_comite_details(dep_number)
    comite_hash = list_comites_by_id[dep_number]
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2024-2025-20/departemental/o-#{comite_hash['libelle'].parameterize}-#{comite_hash['ext_structureId']}/",
      'competitions---competition-main-menu'
    )
  end

  def fetch_competition_details(competition_key)
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2024-2025-20/departemental/#{competition_key.gsub('_', '-')}/",
      'competitions---poule-selector'
    )
  end

  def fetch_competition_stats(competition_key, phase_id, code_pool)
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2024-2025-20/departemental/#{competition_key.gsub('_', '-')}/poule-#{code_pool}/statistiques/",
      'competitions---stats-joueurs'
    )
  end

  def fetch_pool_details(competition_key, code_pool)
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2024-2025-20/departemental/#{competition_key.gsub('_', '-')}/poule-#{code_pool}/",
      'competitions---poule-selector'
    )
  end

  def fetch_journee_details(competition_key, code_pool, journee_number)
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2024-2025-20/departemental/#{competition_key.gsub('_', '-')}/poule-#{code_pool}/journee-#{journee_number}/",
      'competitions---rencontre-list'
    )
  end

  def fetch_match_details(competition_key, code_pool, rencontre_id)
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2024-2025-20/departemental/#{competition_key.gsub('_', '-')}/poule-#{code_pool}/rencontre-#{rencontre_id}/",
      'competitions---rematch'
    )
  end

  def fetch_rencontre_salle(competition_key, code_pool, rencontre_id)
    fetch_smartfire_attributes(
      "https://www.ffhandball.fr/competitions/saison-2024-2025-20/departemental/#{competition_key.gsub('_', '-')}/poule-#{code_pool}/rencontre-#{rencontre_id}/",
      'competitions---rencontre-salle'
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

  def build_specific_calendar(pool_details, name, team_links, enrolled_team_championships, linked_calendar = nil)
    # list teams that interest us
    ffhb_team_ids = enrolled_team_championships.select do |etc|
      team_links.values.map(&:to_i).include?(etc.team_id)
    end.map(&:ffhb_team_id)

    enrolled_team_championships_by_ffhb_team_id = enrolled_team_championships.index_by(&:ffhb_team_id)

    calendar = linked_calendar || Calendar.new(season: Season.current, name:)
    matches = []

    I18n.locale = :fr

    journees = Oj.load(pool_details['selected_poule']['journees'])

    journees.each do |journee|
      period_start_date = Date.parse(journee['date_debut'])
      period_end_date = Date.parse(journee['date_fin'])
      day_name = "WE du #{I18n.l(period_start_date, format: :short)} au #{I18n.l(period_end_date, format: :short)}"

      day = find_or_create_day(calendar, day_name, period_start_date.beginning_of_week, period_end_date)

      journee_details = fetch_journee_details(pool_details['url_competition'], pool_details['ext_poule_id'],
                                              journee['journee_numero'])

      journee_details['rencontres'].each do |match|
        next unless ffhb_team_ids.intersect?([match['equipe1Id'], match['equipe2Id']])

        local_team = enrolled_team_championships_by_ffhb_team_id[match['equipe1Id']].team
        visitor_team = enrolled_team_championships_by_ffhb_team_id[match['equipe2Id']].team
        ffhb_key = "#{pool_details['url_competition']} #{pool_details['ext_poule_id']} #{match['ext_rencontreId']}"
        matches << Match.new(local_team:, visitor_team:, day:, ffhb_key:)
      end
    end

    [calendar, matches]
  end

  def find_or_create_day(calendar, day_name, period_start_date, period_end_date)
    day = calendar.days.find_by(name: day_name)
    if day.blank?
      day = Day.new(name: day_name, period_start_date:, period_end_date:)
      calendar.days << day
    end
    day
  end

  def build_teams(pool_details, team_links = {})
    team_links = {} if team_links.blank?

    pool_details['equipe_options'].map do |ffhb_team|
      name = ffhb_team['libelle']
      ext_equipe_id = ffhb_team['ext_equipeId']
      team =
        if team_links[ext_equipe_id].present?
          Team.find(team_links[ext_equipe_id])
        else
          Team.new name:, club: Club.new(name:)
        end
      EnrolledTeamChampionship.new(team:, enrolled_name: name, ffhb_team_id: ffhb_team['id'])
    end
  end

  def build_championship(type_competition:, code_comite:, code_competition:, phase_id:, code_pool:, team_links:, linked_calendar: nil) # rubocop:disable Metrics/ParameterLists
    comite_details = fetch_comite_details(code_comite.to_i)
    pool_details = fetch_pool_details(code_competition, code_pool)

    comite_name = comite_details['structure']['libelle']
    competition_name = comite_details['competitions'].find do |c|
                         c['ext_competitionId'] == code_competition[/(\d+)$/]
                       end['libelle']
    name = "#{comite_name} - #{competition_name}"

    saison = "#{comite_details['saison']['libelle'].gsub(/\s+/, '')}-#{comite_details['saison']['ext_saisonId']}"
    ffhb_key = "#{saison} #{comite_details['url_competition_type']} #{pool_details['url_competition']} #{pool_details['selected_poule']['phaseId']} #{pool_details['selected_poule']['ext_pouleId']}"

    enrolled_team_championships = build_teams(pool_details, team_links)
    calendar, matches = build_specific_calendar(pool_details, name, team_links, enrolled_team_championships,
                                                linked_calendar)

    Championship.new(name:, calendar:, ffhb_key:, enrolled_team_championships:, matches:)
  end
end
