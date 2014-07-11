class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
    @user = User.find params[:id]
    if current_user != @user
      render text: "Access denied."
    end

  end

end
