class UsersController < ApplicationController
  before_action :find_user_by_id, except: :index
  skip_before_action :verify_authenticity_token, only: [:training_presences, :match_availabilities]

  def index
    if current_section
      @users = User.joins(:participations).where(participations: { section: current_section, season: Season.current })
    else
      @users = User.all
    end
    @users = @users.order('last_name ASC').distinct
  end

  def show
    if current_user != @user
      render body: "Access denied."
    end
  end

  def edit
    @return_to = params[:returns_to]
  end

  def update
    @user.update_attributes! user_params
    if params[:return_to]
      redirect_to params[:return_to]
    elsif current_section
      redirect_to section_user_path(@user, section_id: current_section.to_param)
    else
      redirect_to user_path(@user, section_id: current_section.to_param)
    end
  end

  def training_presences
    present_ids = (params[:present_ids] || []).map(&:to_i)
    checked_ids = (params[:checked_ids] || []).map(&:to_i)

    TrainingPresence.where(training_id: present_ids, user_id: current_user.id).delete_all

    trainings = Training.where(id: present_ids)
    trainings.each do |training|
      TrainingPresence.create! user: current_user, training: training, present: checked_ids.include?(training.id)
    end

    redirect_to referer_url_or(root_path)
  end

  def match_availabilities
    if @user != current_user && !current_user.is_coach_of?(current_section)
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
      return
    end

    present_ids = (params[:present_ids] || []).map(&:to_i)
    checked_ids = (params[:checked_ids] || []).map(&:to_i)

    MatchAvailability.where(match_id: present_ids, user_id: @user.id).delete_all

    matches = Match.where(id: present_ids)
    matches.each do |match|
      MatchAvailability.create! user: @user, match: match, available: checked_ids.include?(match.id)
    end

    redirect_to referer_url_or(root_path)
  end

  def destroy
    group_id = params[:group_id]
    if group_id
      group = Group.find group_id
      group.remove_user!(@user)
      redirect_to section_group_path(current_section, group)
    else
      current_section.remove_member!(@user)
      redirect_to section_users_path(current_section)
    end
  end

  protected

  def find_user_by_id
    user_key = params[:user_id] ? :user_id : :id
    @user = User.find params[user_key]
  rescue ActiveRecord::RecordNotFound
    handle_404
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :nickname, :phone_number)
  end
end
