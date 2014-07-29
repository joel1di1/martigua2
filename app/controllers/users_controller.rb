class UsersController < ApplicationController

  before_filter :find_user_by_id, except: :index

  def index
    if current_section
      @users = current_section.users
    else
      @users = User.all
    end
  end

  def show
    if current_user != @user
      render text: "Access denied."
    end
  end

  def edit
  end

  def update
    @user.update_attributes! user_params
    if current_section
      redirect_to section_user_path(@user, section_id: current_section.to_param)
    else
      redirect_to user_path(@user, section_id: current_section.to_param)
    end
  end


  protected 
    def find_user_by_id
      @user = User.find params[:id]
    rescue ActiveRecord::RecordNotFound
      handle_404
    end

  private
    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :nickname, :phone_number)
    end
end
