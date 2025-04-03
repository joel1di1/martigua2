# frozen_string_literal: true

class ChampionshipsController < ApplicationController
  before_action :find_championship_by_id, except: %i[index new create]

  TYPE_COMPETITION = [
    %w[Régions R].freeze,
    %w[Départements D].freeze
  ].freeze

  def index
    scope = current_section ? current_section.championships : Championship
    @championships = scope.where(season: Season.current).order(created_at: :desc)
  end

  def show; end

  def new
    @championship = Championship.new championship_params

    return if params['ffhb'].blank?

    return if params['type_competition'].blank?

    @comites_options = FfhbService.instance.list_comites_by_id.map do |dep_number, comite_hash|
      ["#{dep_number} - #{comite_hash['libelle']}", dep_number]
    end.sort_by(&:second)

    return if params['code_comite'].blank?

    @competitions_options = FfhbService.instance.list_competitions(params['code_comite'].to_i).map do |competition_hash|
      [competition_hash['libelle'],
       "#{competition_hash['libelle'].parameterize}-#{competition_hash['ext_competitionId']}"]
    end.sort_by(&:first)

    return if params['code_competition'].blank?

    @competition_details = FfhbService.instance.fetch_competition_details(params['code_competition'])

    @phases_options = @competition_details['phases'].map { |phase| [phase['libelle'], phase['id']] }

    return if params['phase_id'].blank?

    @pools_options = @competition_details['poules']
                     .select { |poule| poule['phaseId'] == params['phase_id'] }
                     .map { |poule| [poule['libelle'], poule['ext_pouleId']] }

    return if params['code_pool'].blank?

    @teams = FfhbService.instance.list_teams_for_pool(params['code_competition'], params['code_pool'])

    @calendars = current_section.season_calendars
  end

  def edit; end

  def create
    all_params = %w[type_competition code_comite code_competition phase_id code_pool ffhb team_links]
    if params['ffhb'].present?
      if all_params.any? { |param| params[param].blank? }
        redirect_to new_section_championship_path(current_section, params: params.permit(all_params))
      else
        permitted_params = params.permit(all_params).to_h.except(:ffhb).symbolize_keys
        permitted_params[:team_links] = params[:team_links].permit!.to_h
        if params[:championship] && params[:championship][:calendar].present?
          linked_calendar = Calendar.find(params[:championship][:calendar])
        end
        @championship = Championship.create_from_ffhb!(**permitted_params, linked_calendar:)
        redirect_with additionnal_params: { 'match[championship_id]' => @championship.id },
                      fallback: section_championship_path(current_section, @championship),
                      use_referrer: false,
                      notice: 'Compétition créée'
      end
    else
      @championship = Championship.new championship_params
      @championship.season = Season.current
      if @championship.save
        @championship.enroll_team! Team.find_by(id: params[:default_team_id]) if params[:default_team_id].present?

        redirect_with additionnal_params: { 'match[championship_id]' => @championship.id },
                      fallback: section_championship_path(current_section, @championship),
                      use_referrer: false,
                      notice: 'Compétition créée'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update
    if @championship.update(championship_params)
      redirect_to section_championship_path(current_section, @championship), notice: 'Compétition sauvegardée'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  protected

  def championship_params
    if params[:championship]
      params.expect(championship: [:name, :calendar_id, { team_ids: [] }])
    else
      {}
    end
  end

  def find_championship_by_id
    @championship = Championship.find params[:id]
  rescue ActiveRecord::RecordNotFound
    catch404
  end
end
