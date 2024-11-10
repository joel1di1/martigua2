# frozen_string_literal: true

class SectionInviteService
  def initialize(section, params, inviter)
    @section = section
    @params = params
    @inviter = inviter
  end

  def call
    column_names = SectionUserInvitation.column_names
    column_syms = column_names.map(&:to_sym)
    params_only = @params.slice(*column_syms)
    params_only_with_section = params_only.merge(section: @section)
    invitation = SectionUserInvitation.create!(params_only_with_section)

    user = User.find_by(email: invitation.email)

    if user.present?
      UserMailer.send_section_addition_to_existing_user(user, @inviter, @section).deliver_later
    else
      user = User.invite!(params_only.delete_if { |k, _v| k.to_s == 'roles' }, @inviter)
    end

    user
  end
end
