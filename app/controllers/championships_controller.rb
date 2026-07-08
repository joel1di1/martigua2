# frozen_string_literal: true

class ChampionshipsController < ApplicationController
  include PrefetchMatchData

  before_action :find_championship_by_id, except: %i[index new create]

  def index
    scope = current_section ? current_section.championships : Championship
    @championships = scope.where(season: Season.current).order(created_at: :desc)
    @match_counts_by_championship_id = Match.where(championship_id: @championships.unscope(:order).ids).group(:championship_id).count
  end

  def show
    @section = current_section
    @burns = @championship.burns.to_a
    @new_burn = @championship.burns.build
    @next_matches = @championship.matches.join_day.date_ordered.includes(
      :local_team,
      :visitor_team,
      :day,
      :location,
      :championship,
      match_availabilities: :user
    )
    preload_match_data
  end

  def new
    @championship = Championship.new championship_params
  end

  def edit; end

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
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @championship.update(championship_params)
      redirect_to section_championship_path(current_section, @championship), notice: 'Compétition sauvegardée'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def update_group
    @championship.championship_group_championships.destroy_all
    if params[:championship_group_id].present?
      ChampionshipGroup.find(params.expect(:championship_group_id)).add_championship(@championship, index: params[:index].to_i)
    end
    redirect_to section_championship_path(current_section, @championship), notice: 'Groupe mis à jour'
  end

  def merge_calendar_form
    section_championship_ids = current_section.championships.pluck(:id)

    @available_championships = Championship
                               .where(id: section_championship_ids)
                               .where(season: @championship.season)
                               .where.not(id: @championship.id)
                               .order(:name)
  end

  def merge_calendar
    other_championship = Championship.find(params.expect(:other_championship_id))

    # Verify both championships belong to current section
    section_championship_ids = current_section.championships.pluck(:id)
    if section_championship_ids.include?(@championship.id) && section_championship_ids.include?(other_championship.id)
      result = @championship.merge_calendar_from(other_championship)

      if result[:success]
        redirect_to section_championship_path(current_section, @championship),
                    notice: "Calendrier fusionné avec succès depuis #{other_championship.name}"
      else
        redirect_to section_championship_path(current_section, @championship),
                    alert: "Échec de la fusion du calendrier : #{result[:error]}"
      end
    else
      redirect_to section_championship_path(current_section, @championship),
                  alert: 'Vous ne pouvez fusionner que des calendriers de championnats de votre section'
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
    @championship = Championship.find params.expect(:id)
    verify_section_ownership!(:championships, id: @championship.id)
  rescue ActiveRecord::RecordNotFound
    catch404
  end
end
