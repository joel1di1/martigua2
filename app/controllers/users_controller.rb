class UsersController < ApplicationController

  before_filter :find_user_by_id, except: :index
  skip_before_filter :verify_authenticity_token, only: [:training_presences]

  def index
    if current_section
      @users = current_section.users
    else
      @users = User.all
    end
    @users = @users.order('last_name ASC')
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

  def training_presences
    present_ids = ( params[:present_ids] || [] ).map(&:to_i)
    checked_ids = ( params[:checked_ids] || [] ).map(&:to_i)

    TrainingPresence.where(training_id: present_ids, user_id: current_user.id).delete_all
    
    trainings = Training.where(id: present_ids)
    trainings.each do |training|
      TrainingPresence.create! user: current_user, training: training, present: checked_ids.include?(training.id)
    end

    redirect_to referer_url_or(root_path)
  end

  def destroy
    group_id = params[:group_id]
    if group_id
      group = Group.find group_id
      raise 'you cannot remove usr from system group' if group.system?
      group.remove_user(@user)
      redirect_to section_group_path(current_section, group)
    else
      current_section.remove_member!(@user) if current_section.has_member?(@user)
      redirect_to section_users_path(current_section)
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
