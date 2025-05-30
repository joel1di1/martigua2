# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :find_group

  def index
    @groups = current_section.groups.where(season: Season.current).order('system ASC, name ASC')
  end

  def show
    @users = @group.users.includes(:participations, :groups)
    @last_trainings, @presences_by_user_and_training = prepare_training_presences(current_section, @users)
  end

  def new
    @group = Group.new section: current_section
  end

  def create
    @group = Group.new group_params
    @group.section = current_section
    @group.season = Season.current
    if @group.save
      redirect_to section_group_path(current_section, @group), notice: 'Groupe créé'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @group.update group_params
      redirect_to section_group_path(current_section, @group), notice: 'Groupe modifié'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def add_users
    user = User.find params[:user_id]
    @group.add_user! user
    redirect_to section_group_path(current_section, @group), notice: 'Joueur ajouté au groupe'
  end

  def destroy
    @group.destroy
    redirect_to section_groups_path(current_section), notice: "Groupe '#{@group.name}' supprimé"
  end

  private

  def group_params
    params.expect(group: %i[name color description])
  end

  def find_group
    id = params[:id] || params[:group_id]
    @group = Group.find id if id
  end
end
