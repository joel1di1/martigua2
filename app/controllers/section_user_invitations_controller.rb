# frozen_string_literal: true

class SectionUserInvitationsController < ApplicationController
  def new
    @section_user_invitation = SectionUserInvitation.new section: current_section
  end

  def create
    current_section.invite_user! section_user_invitation_params, current_user
    redirect_to new_section_section_user_invitation_path(section_id: current_section.to_param),
                notice: "#{section_user_invitation_params[:email]} invité !"
  end

  private

  def section_user_invitation_params
    params.expect(section_user_invitation: %i[email first_name last_name nickname phone_number
                                              section_id roles])
  end
end
