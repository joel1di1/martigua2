class UsersController < ApplicationController

  def index
    @users = User.all
    @users = @users.joins(:participations).where(participations: { section: current_section } ) if current_section
  end

  def show
    @user = User.find params[:id]
    if current_user != @user
      render text: "Access denied."
    end

  end

end
