# frozen_string_literal: true

class ChampionshipsController < ApplicationController
  before_action :find_championship_by_id, except: %i[index new create]

  def index
    scope = current_section ? current_section.championships : Championship
    @championships = scope.where(season: Season.current).order(created_at: :desc)
  end

  def new
    @championship = Championship.new championship_params
  end

  def create
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

  def show; end

  def edit; end

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
