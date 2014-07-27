class UsersController < ApplicationController

  def index
    if current_section
      @users = current_section.users
    else
      @users = User.all
    end
  end

  def show
    @user = User.find params[:id]
    if current_user != @user
      render text: "Access denied."
    end

  end

end
