# frozen_string_literal: true

# Exposes the admin behind a switch_user impersonation, for the navbar badge and the
# switch_user widget. Mirrors SwitchUserHelper#provider without relying on its private API.
module ImpersonationHelper
  def impersonation_original_user
    original_user = SwitchUser::Provider.init(controller).original_user
    original_user if original_user && original_user != current_user
  end

  def impersonating?
    impersonation_original_user.present?
  end
end
