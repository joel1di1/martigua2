# frozen_string_literal: true

class ChampionshipsController < ApplicationController
  before_action :find_championship_by_id, except: %i[index new create]

  TYPE_COMPETITION = [
    %w[National national].freeze,
    %w[Régions regions].freeze,
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

    @comites = FfhbService.instance.fetch_ffhb_url_as_json "championship/#{params['type_competition']}"

    return if params['code_comite'].blank?

    @divisions = FfhbService.instance.fetch_ffhb_url_as_json "competition/#{params['code_comite']}"

    return if params['code_division'].blank?

    @pools = FfhbService.instance.fetch_ffhb_url_as_json "competitionPool/#{params['code_division']}"

    return if params['code_pool'].blank?

    @competition = FfhbService.instance.fetch_ffhb_url_as_json "pool/#{params['code_pool']}"
  end

  def edit; end

  def create
    all_params = %w[type_competition code_comite code_division code_pool ffhb team_links]
    if params['ffhb'].present?
      if all_params.any? { |param| params[param].blank? }
        redirect_to new_section_championship_path(current_section, params: params.permit(all_params))
      else
        permitted_params = params.permit(all_params).to_h.except(:ffhb).symbolize_keys
        permitted_params[:team_links] = params[:team_links].permit!.to_h
        @championship = Championship.create_from_ffhb!(**permitted_params)
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
      params.require(:championship).permit(:name, :calendar_id, team_ids: [])
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
