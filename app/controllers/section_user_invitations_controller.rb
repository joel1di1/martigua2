class SectionUserInvitationsController < ApplicationController

  def new 
    @section_user_invitation = SectionUserInvitation.new section: current_section
  end

  def create
    current_section.invite_user! section_user_invitation_params, current_user
    redirect_to section_users_path(current_section), notice: "#{section_user_invitation_params[:email]} invité !"
  end

  private 
    def section_user_invitation_params
      params.require(:section_user_invitation).permit(:email, :first_name, :last_name, :nickname, :phone_number, :section_id, :roles)
    end
end