# frozen_string_literal: true

module Ffhb
  # Backs the step-by-step FFHB championship import form: each selected step
  # unlocks the options of the next one (comité → compétition → phase → poule → teams).
  class ImportForm
    TYPE_COMPETITION_OPTIONS = [
      %w[Régions R].freeze,
      %w[Départements D].freeze
    ].freeze

    STEP_PARAMS = %w[type_competition code_comite code_competition phase_id code_pool].freeze

    STEP_PARAMS.each do |step_param|
      define_method(step_param) { @params[step_param] }
    end

    def initialize(params)
      @params = params.respond_to?(:permit) ? params.permit(STEP_PARAMS).to_h : params.stringify_keys
    end

    def complete?
      STEP_PARAMS.all? { |step_param| @params[step_param].present? }
    end

    # The selected step values, e.g. to rebuild the form URL after an incomplete submit.
    def to_params
      @params.slice(*STEP_PARAMS).symbolize_keys
    end

    def comites_options
      return if type_competition.blank?

      FfhbService.instance.list_comites_by_id.map do |dep_number, comite_hash|
        ["#{dep_number} - #{comite_hash['libelle']}", dep_number]
      end.sort_by(&:second)
    end

    def competitions_options
      return if code_comite.blank?

      FfhbService.instance.list_competitions(code_comite.to_i).map do |competition_hash|
        [competition_hash['libelle'],
         "#{competition_hash['libelle'].parameterize}-#{competition_hash['ext_competitionId']}"]
      end.sort_by(&:first)
    end

    def phases_options
      return if code_competition.blank?

      competition_details['phases'].map { |phase| [phase['libelle'], phase['id']] }
    end

    def pools_options
      return if phase_id.blank?

      competition_details['poules']
        .select { |poule| poule['phaseId'] == phase_id }
        .map { |poule| [poule['libelle'], poule['ext_pouleId']] }
    end

    def teams
      return if code_pool.blank?

      FfhbService.instance.list_teams_for_pool(code_competition, code_pool)
    end

    private

    def competition_details
      @competition_details ||= FfhbService.instance.fetch_competition_details(code_competition)
    end
  end
end
