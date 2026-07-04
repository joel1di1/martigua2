# frozen_string_literal: true

module Ffhb
  # Refreshes a single match from the FFHB: date, day, scores, fdm code and location.
  class MatchSync
    def initialize(match)
      @match = match
    end

    def call
      if match.ffhb_key.blank?
        Rails.logger.warn "No ffhb_key for match #{match.id}"
        return
      end

      match_details = FfhbService.instance.fetch_match_details(*match.ffhb_key.split)
      sync_datetime(match_details)
      sync_scores(match_details)
      sync_location(match_details)

      match.save!
    rescue FfhbServiceError => e
      capture_sync_failure(e)
    end

    private

    attr_reader :match

    def sync_datetime(match_details)
      return if match_details['rencontre']['date'].blank?

      match.start_datetime = Time.find_zone('UTC').parse(match_details['rencontre']['date'])
      match.day = match.championship.find_or_create_day_for(match.start_datetime)
    end

    def sync_scores(match_details)
      match.local_score = match_details['rencontre']['equipe1Score']&.to_i
      match.visitor_score = match_details['rencontre']['equipe2Score']&.to_i
      match.fdm_code = match_details['rencontre']['fdmCode']
    end

    def sync_location(match_details)
      ffhb_id = match_details['rencontre']['equipementId']
      return if ffhb_id.blank?

      match.location = Location.find_by(ffhb_id:) || create_location(ffhb_id)
    end

    def create_location(ffhb_id)
      rencontre_details = FfhbService.instance.fetch_rencontre_salle(*match.ffhb_key.split)
      name = rencontre_details['equipement']['libelle']
      address = <<~TEXT.chomp
        #{rencontre_details['equipement']['libelle']}
        #{rencontre_details['equipement']['rue']}
        #{rencontre_details['equipement']['codePostal']} #{rencontre_details['equipement']['ville']}
      TEXT

      Location.create!(name:, address:, ffhb_id:)
    end

    def capture_sync_failure(error)
      Sentry.capture_message(
        'FFHB sync failed for match - possibly deleted match (team banished?)',
        level: :warning,
        extra: {
          error_message: error.message,
          match_id: match.id,
          match_ffhb_key: match.ffhb_key,
          championship_id: match.championship_id,
          championship_ffhb_key: match.championship.ffhb_key,
          season_id: match.championship.season_id
        }
      )
      Rails.logger.warn "FFHB sync failed for match #{match.id}: #{error.message}"
    end
  end
end
