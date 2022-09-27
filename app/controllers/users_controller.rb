# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user_by_id, except: :index
  skip_before_action :verify_authenticity_token, only: %i[training_presences match_availabilities]

  def index
    if current_section
      @users = current_section.members.includes(:participations, :groups_users, :groups)
      @last_trainings, @presences_by_user_and_training = prepare_training_presences(current_section, @users)
    else
      @users = User.all
    end
    @users = @users.order('first_name, last_name')
  end

  def show
    render body: 'Access denied.' if current_user != @user
  end

  def edit
    @return_to = params[:returns_to]
  end

  def update
    if current_section.present? && [params[:coach], params[:player]].compact.empty?
      flash[:error] = 'Gardez un role ou utilisez le bouton supprimer'
      redirect_with(fallback: section_users_path(current_section))
      return
    end

    @user.update! user_params

    if current_section.present?
      roles = [params[:coach], params[:player]].compact
      current_section.update_roles!(@user, roles)
    end

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
      TrainingPresence.create! user: current_user, training:, is_present: checked_ids.include?(training.id)
    end

    redirect_with(fallback: root_path)
  end

  def match_availabilities
    if @user != current_user && !current_user.coach_of?(current_section)
      render(file: Rails.public_path.join('403.html'), status: :forbidden, layout: false)
      return
    end

    present_ids = (params[:present_ids] || []).map(&:to_i)
    checked_ids = (params[:checked_ids] || []).map(&:to_i)

    MatchAvailability.where(match_id: present_ids, user_id: @user.id).delete_all

    matches = Match.where(id: present_ids)
    matches.each do |match|
      MatchAvailability.create! user: @user, match:, available: checked_ids.include?(match.id)
    end

    redirect_with(fallback: root_path)
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
    catch404
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :nickname, :phone_number)
  end
end
