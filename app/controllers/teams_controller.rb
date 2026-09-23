# frozen_string_literal: true

class TeamsController < ApplicationController
  before_action :set_current_team, only: %i[show edit update destroy]
  before_action :verify_coach!, only: %i[new edit update destroy]

  def index
    @teams = current_section.teams.order(:name)
  end

  def show; end

  def new
    @team = Team.new(club: current_section&.club)
  end

  def edit; end

  # This action is shared with the "add adversary team" panel used by the match creation
  # wizard (see matches/_new_team_panel.html.slim), which posts to this very same route
  # without going through the section's team management (no coach check, no section
  # attachment). We tell the two usages apart based on the params the wizard always sends.
  def create
    @team = Team.new team_params
    return create_from_wizard if wizard_request?

    verify_coach!
    return if performed?

    create_for_section
  end

  def update
    if @team.update(team_params)
      redirect_to section_teams_path(current_section), notice: 'Équipe modifiée'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @team.matches.exists?
      redirect_to section_teams_path(current_section),
                  alert: "Impossible de supprimer l'équipe #{@team.name} : elle a déjà des matchs enregistrés"
    else
      @team.destroy
      redirect_to section_teams_path(current_section), notice: 'Équipe supprimée'
    end
  end

  private

  def create_from_wizard
    @team.club_id ||= Club.find_or_create_by(name: 'Les Connards').id
    @team.save!

    if params[:championship_id].present?
      championship = Championship.find(params.expect(:championship_id))
      championship.enroll_team! @team
    end

    respond_to do |format|
      format.html do
        redirect_with additionnal_params: { adversary_team_id: @team.id }, notice: 'Équipe créée'
      end
      format.turbo_stream
    end
  end

  def create_for_section
    @team.club ||= current_section.club
    @team.sections << current_section if @team.sections.exclude?(current_section)

    if @team.save
      redirect_to section_teams_path(current_section), notice: 'Équipe créée'
    else
      render :new, status: :unprocessable_content
    end
  end

  def wizard_request?
    params[:_redirect_url].present? || params[:championship_id].present?
  end

  def team_params
    params.expect(team: [:name, :club_id, { section_ids: [] }])
  end

  def set_current_team
    @team = current_section.teams.find(params.expect(:id)) if params[:id]
  rescue ActiveRecord::RecordNotFound
    catch404
  end

  def verify_coach!
    return if current_user&.coach_of?(current_section)
    return if current_user&.admin_of?(current_section&.club)
    return if current_user&.super_admin?

    respond_to do |format|
      format.html { render(file: Rails.public_path.join('403.html'), status: :forbidden, layout: false) }
      format.json { head :forbidden }
    end
  end
end
