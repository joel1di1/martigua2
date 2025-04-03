# frozen_string_literal: true

class AbsencesController < ApplicationController
  before_action :set_absence, only: %i[edit update destroy]
  before_action :set_user

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
        format.html { redirect_to section_user_path(current_section, @user), notice: 'Blessure créée' }
        format.json { render :show, status: :created, location: @absence }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @absence.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @absence.update(absence_params)
        format.html { redirect_to section_user_path(current_section, @user), notice: 'Absence was successfully updated.' }
        format.json { render :show, status: :ok, location: @absence }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @absence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /absences/1 or /absences/1.json
  def destroy
    @absence.destroy!

    respond_to do |format|
      format.html { redirect_with fallback: section_user_path(current_section, @user), notice: 'Absence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_absence
    @absence = Absence.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  # Only allow a list of trusted parameters through.
  def absence_params
    params.expect(absence: %i[start_at end_at name comment])
  end
end
