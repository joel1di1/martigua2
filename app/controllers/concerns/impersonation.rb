# frozen_string_literal: true

# Exposes the admin behind a switch_user impersonation, for the navbar badge and the
# switch_user widget (app/views/switch_user/_widget.html.slim).
module Impersonation
  extend ActiveSupport::Concern

  included do
    helper_method :impersonation_original_user, :impersonating?
  end

  # nil when nobody is impersonated, or when the admin "remembered" themselves.
  def impersonation_original_user
    return @impersonation_original_user if defined?(@impersonation_original_user)

    original_user = SwitchUser::Provider.init(self).original_user
    original_user = nil if original_user == current_user
    @impersonation_original_user = original_user
  end

  def impersonating?
    impersonation_original_user.present?
  end
end
