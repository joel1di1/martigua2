# frozen_string_literal: true

# Signs the visitor in from the `user_token` of a mailed link (see UserMailer).
module TokenAuthentication
  extend ActiveSupport::Concern

  private

  def authenticate_user_from_token!
    token = params[:user_token].presence
    user  = token && User.find_by_token_for(:email_authentication, token)

    if user
      sign_in user
    elsif token && current_user.blank?
      # A dead link (older than 30 days, or the token was rotated): say so and offer a fresh one.
      redirect_to new_login_link_path, alert: 'Ce lien a expiré. Indique ton adresse pour en recevoir un nouveau.'
    end
  end
end
