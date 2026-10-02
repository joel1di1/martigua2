# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include SendsLoginLinks

    rate_limit to: 5, within: 1.minute, only: :create
    prepend_before_action :send_login_links_if_passwordless, only: :create # rubocop:disable Rails/LexicallyScopedActionFilter
  end
end
