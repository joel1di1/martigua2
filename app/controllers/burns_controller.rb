# frozen_string_literal: true

class BurnsController < ApplicationController
  before_action :set_championship

  def index
    @burns = @championship.burns
  end

  def create
    @user = current_section.users.find(params[:burn][:user])

    @championship.burn!(@user)

    redirect_with fallback: section_championship_path(current_section, @championship),
                  notice: "#{@user.full_name} brûlé !"
  end

  def destroy
    burn = @championship.burns.find(params[:id])
    user = burn.user

    burn.delete

    redirect_with fallback: section_championship_path(current_section, @championship),
                  notice: "#{user.full_name} rétabli"
  end

  protected

  def set_championship
    @championship = Championship.find(params[:championship_id])
  end
end
