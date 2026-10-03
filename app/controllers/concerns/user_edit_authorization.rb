# frozen_string_literal: true

# A user's profile and absences can be edited by the user, or by a coach of the section named
# in the url. Without a section in the url (/users/:id), only the user themselves.
module UserEditAuthorization
  extend ActiveSupport::Concern

  included do
    helper_method :can_edit_user?
  end

  protected

  def can_edit_user?(user)
    user == current_user || (current_section.present? && current_user.coach_of?(current_section))
  end

  def verify_can_edit_user
    return if can_edit_user?(@user)

    render(file: Rails.public_path.join('403.html'), status: :forbidden, layout: false)
  end
end
