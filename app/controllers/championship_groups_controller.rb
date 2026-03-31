# frozen_string_literal: true

class ChampionshipGroupsController < ApplicationController
  before_action :set_championship_group, only: %i[show edit update destroy add_championship remove_championship]

  def index
    @championship_groups = section_championship_groups
  end

  def show
    @section_championships = current_section.championships.where(season: Season.current).order(:name)
    @memberships = @championship_group.championship_group_championships.includes(:championship).order(:index)
  end

  def new
    @championship_group = ChampionshipGroup.new
  end

  def edit; end

  def create
    @championship_group = ChampionshipGroup.new(championship_group_params)
    if @championship_group.save
      redirect_to section_championship_group_path(current_section, @championship_group), notice: 'Groupe créé'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @championship_group.update(championship_group_params)
      redirect_to section_championship_group_path(current_section, @championship_group), notice: 'Groupe modifié'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @championship_group.destroy!
    redirect_to section_championship_groups_path(current_section), notice: 'Groupe supprimé'
  end

  def add_championship
    championship = current_section.championships.find(params[:championship_id])
    index = params[:index].to_i
    championship.championship_group_championships.where(championship_group: @championship_group).destroy_all
    @championship_group.add_championship(championship, index:)
    redirect_to section_championship_group_path(current_section, @championship_group), notice: 'Compétition ajoutée au groupe'
  end

  def remove_championship
    championship = current_section.championships.find(params[:championship_id])
    championship.championship_group_championships.where(championship_group: @championship_group).destroy_all
    redirect_to section_championship_group_path(current_section, @championship_group), notice: 'Compétition retirée du groupe'
  end

  private

  def set_championship_group
    @championship_group = ChampionshipGroup.find(params[:id])
  end

  def championship_group_params
    params.expect(championship_group: [:name])
  end

  def section_championship_groups
    ChampionshipGroup
      .joins(championships: { teams: :team_sections })
      .where(team_sections: { section_id: current_section.id })
      .distinct
      .order(:name)
  end
end
