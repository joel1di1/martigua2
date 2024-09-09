# frozen_string_literal: true

module Ffhb
  module Mock
    def load_json_content(filename)
      mocks_path = Rails.root.join('spec/fixtures/ffhb/2023')
      file_content = File.read(mocks_path.join(filename))
      Oj.load(file_content)
    end

    def mock_ffhb
      # mock fetch_departemental_details
      allow(FfhbService.instance).to receive(:fetch_departemental_details) do
        load_json_content('fetch_departemental_details.json')
      end

      allow(FfhbService.instance).to receive(:fetch_competition_details) do |competition_key|
        load_json_content("fetch_competition_details_#{competition_key}.json")
      end

      # mock fetch_comite_details
      allow(FfhbService.instance).to receive(:fetch_comite_details) do |comite_id|
        load_json_content("fetch_comite_details_#{comite_id}.json")
      end

      # mock fetch_pool_details
      allow(FfhbService.instance).to receive(:fetch_pool_details) do |competition_url, pool_code|
        load_json_content("fetch_pool_details_#{competition_url}_#{pool_code}.json")
      end

      # mock fetch_journee_details
      allow(FfhbService.instance).to receive(:fetch_journee_details) do |competition_url, pool_code, journee_number|
        filename = "fetch_journee_details_#{competition_url}_#{pool_code}_#{journee_number}.json"
        load_json_content(filename)
      end

      # mock fetch_match_details
      allow(FfhbService.instance).to receive(:fetch_match_details) do |competition_url, pool_code, rencontre_id|
        filename = "fetch_match_details_#{competition_url}_#{pool_code}_#{rencontre_id}.json"
        load_json_content(filename)
      end

      # mock fetch_rencontre_salle
      allow(FfhbService.instance).to receive(:fetch_rencontre_salle) do |competition_url, pool_code, rencontre_id|
        filename = "fetch_rencontre_salle_#{competition_url}_#{pool_code}_#{rencontre_id}.json"
        load_json_content(filename)
      end

      # mock fetch_competition_stats
      allow(FfhbService.instance).to receive(:fetch_competition_stats) do |competition_key, _phase_id, code_pool|
        filename = "fetch_competition_stats_#{competition_key}_#{code_pool}_statistiques.json"
        load_json_content(filename)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Ffhb::Mock
end
