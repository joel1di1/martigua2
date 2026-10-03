# frozen_string_literal: true

class AbsencesController < ApplicationController
  include UserEditAuthorization

  before_action :set_user
  before_action :verify_can_edit_user, if: -> { @user }
  before_action :set_absence, only: %i[edit update destroy]

  helper_method :user_profile_path

  # GET /absences or /absences.json
  def index
    @absences = Absence.includes(user: :sections).where(users: { sections: current_section }).order(:start_at)
  end

  # GET /absences/new
  def new
    @absence = Absence.new(user: @user, start_at: Time.zone.today)
  end

  # GET /absences/1/edit
  def edit; end

  # POST /absences or /absences.json
  def create
    @absence = Absence.new(absence_params)
    @absence.user = @user

    respond_to do |format|
      if @absence.save
        format.html { redirect_to user_profile_path, notice: 'Blessure créée' }
        format.json { render :show, status: :created, location: @absence }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @absence.errors, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @absence.update(absence_params)
        format.html do
          redirect_to user_profile_path, notice: 'Absence was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @absence }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @absence.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /absences/1 or /absences/1.json
  def destroy
    @absence.destroy!

    respond_to do |format|
      format.html do
        redirect_with fallback: user_profile_path, notice: 'Absence was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_absence
    @absence = @user.absences.find(params.expect(:id))
  rescue ActiveRecord::RecordNotFound
    catch404
  end

  def set_user
    return unless params[:user_id]

    id = params.expect(:user_id)
    @user = current_section.present? ? current_section.users.find(id) : User.find(id)
  rescue ActiveRecord::RecordNotFound
    catch404
  end

  # Absences are reachable from the section member page or from the sectionless /users/:id profile.
  def user_profile_path
    current_section.present? ? section_user_path(current_section, @user) : user_path(@user)
  end

  # Only allow a list of trusted parameters through.
  def absence_params
    params.expect(absence: %i[start_at end_at name comment])
  end
end
