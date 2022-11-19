# frozen_string_literal: true

class SectionsController < ApplicationController
  before_action :set_section, only: %i[show destroy edit update]
  include PrefetchTrainingData

  def show
    @next_trainings = @section.next_trainings.includes(:groups, :location)
    @next_matches = @section.next_matches.includes(:local_team, :visitor_team, :day, :location)
    @teams = @section.teams

    add_training_prefetch_data(@next_trainings)
  end

  def new
    @section = Section.new(params[:section] ? section_params : nil)

    club = Club.find(params[:club_id])
    @section.club = club
  end

  def edit
    @players = @section.players.order(:first_name, :last_name)
    @user_stats = UserChampionshipStat.where(championship: @section.championships)

    @user_stats = @user_stats.index_by(&:player_id).values

    @associations = UserChampionshipStat.joins(:championship).where(championship: @section.championships).where(championship: { season: Season.current }).index_by(&:user)

    @suggested_associations = (@players - @associations.keys).index_with do |player|
      suggested_user_stat(player, @user_stats)
    end

    @user
  end

  def player_ffhb_association
    players_params = params[:section].permit!
    players_params.each do |key, ffhb_key|
      next unless key.start_with?('player_')

      user_id = key.split('_')[1]
      user = current_section.users.find(user_id)
      UserChampionshipStat.where(player_id: ffhb_key).update_all(user_id: user.id)
    end

    redirect_to edit_section_path(current_section), notice: 'Les associations ont été mises à jour'
  end

  def create
    @section = Section.new section_params
    club = Club.find(params[:club_id])
    @section.club = club

    if @section.save
      @section.add_coach!(current_user)
      respond_to do |format|
        format.json { render json: @section, status: :created }
        format.html do
          redirect_to(section_users_path(section_id: @section.to_param), notice: "Section #{@section.name} créée")
        end
      end
    else
      respond_to do |format|
        format.json { render json: @section, status: :bad_request }
        format.html { redirect_to new_club_section_path(club_id: club.to_param, section: section.attributes) }
      end
    end
  end

  def update
    if @section.update section_params
      redirect_with(fallback: section_path(@section),
                    notice: "Section #{@section.name} modifée")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    raise 'forbidden' unless current_user.admin_of?(@section.club)

    @section.destroy!
    redirect_with(fallback: club_path(@section.club),
                  notice: "Section #{@section.name} supprimée")
  end

  private

  def section_params
    params.require(:section).permit(:name)
  end

  def set_section
    @section = Section.find(params[:id])
  end

  def suggested_user_stat(player, user_stats)
    suggested_user = nil
    suggested_user_score = nil
    user_stats.each do |user_stat|
      player_name = "#{player.first_name} #{player.last_name}".downcase
      user_stat_name = "#{user_stat.first_name} #{user_stat.last_name}".downcase
      score = String::Similarity.levenshtein(player_name, user_stat_name)
      if score == 1
        suggested_user = user_stat
        suggested_user_score = score
        break
      end

      if score > 0.5 && (suggested_user_score.blank? || score > suggested_user_score)
        suggested_user = user_stat
        suggested_user_score = score
      end
    end
    suggested_user
  end

end
