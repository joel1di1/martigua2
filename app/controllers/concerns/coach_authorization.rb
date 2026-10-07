# frozen_string_literal: true

# Coaches of the current section, admins of its club and super admins manage the section
# (teams, training presence validation...). Use `before_action :verify_coach!` to restrict
# an action to them.
module CoachAuthorization
  extend ActiveSupport::Concern

  included do
    helper_method :can_coach_current_section?
  end

  protected

  def can_coach_current_section?
    return false if current_user.blank?

    current_user.coach_of?(current_section) || current_user.admin_of?(current_section&.club) || current_user.super_admin?
  end

  def verify_coach!
    return if can_coach_current_section?

    respond_to do |format|
      format.html { render(file: Rails.public_path.join('403.html'), status: :forbidden, layout: false) }
      format.json { head :forbidden }
      format.turbo_stream { head :forbidden }
    end
  end
end
