# frozen_string_literal: true

class InjuriesController < ApplicationController
  before_action :set_injury, only: %i[show edit destroy]
  before_action :set_user

  # GET /injuries or /injuries.json
  def index
    @injuries = Injury.all
  end

  # GET /injuries/new
  def new
    @injury = Injury.new(user: @user)
  end

  # GET /injuries/1/edit
  def edit; end

  # POST /injuries or /injuries.json
  def create
    @injury = Injury.new(injury_params)
    @injury.user = @user

    respond_to do |format|
      if @injury.save
        format.html { redirect_to section_user_path(current_section, @user), notice: 'Blessure créée' }
        format.json { render :show, status: :created, location: @injury }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @injury.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /injuries/1 or /injuries/1.json
  def destroy
    @injury.destroy!

    respond_to do |format|
      format.html { redirect_with fallback: section_user_path(current_section, @user), notice: 'Injury was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_injury
    @injury = Injury.find(params[:id])
  end
  def set_user
    @user = User.find(params[:user_id])
  end

  # Only allow a list of trusted parameters through.
  def injury_params
    params.require(:injury).permit(:start_at, :end_at, :name, :comment)
  end
end
