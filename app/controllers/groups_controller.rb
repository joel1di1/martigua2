class GroupsController < ApplicationController

  before_filter :find_group, only: [:show, :add_users, :destroy]

  def show
  end

  def new 
    @group = Group.new section: current_section
  end

  def create 
    @group = Group.new group_params
    @group.section = current_section
    if @group.save
      redirect_to section_group_path(current_section, @group), notice: 'Groupe créé'
    else
      render :new
    end
  end

  def index 
    @groups = current_section.groups
  end

  def destroy
    group.destroy
    redirect_to section_groups_path(current_section), notice: "Groupe '#{group.name}' supprimé"
  end

  def add_users
    user = User.find params[:user_id]
    @group.add_user! user
    redirect_to section_group_path(current_section, @group), notice: 'Joueur ajouté au groupe'
  end

  private
    def group_params
      params.require(:group).permit(:name, :color, :description)
    end

    def find_group
      id = params[:id] || params[:group_id]
      @group = Group.find id
    end
  
end
