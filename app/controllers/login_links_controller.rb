# frozen_string_literal: true

# Lets someone who receives a player's mails — typically a parent on the player's contact
# emails — ask for a fresh sign-in link between two invitation mails.
class LoginLinksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_user_member_of_section

  rate_limit to: 5, within: 1.minute, only: :create

  def new; end

  def create
    email = params[:email].to_s.strip.downcase

    users_reachable_at(email).each do |user|
      UserMailer.send_login_link(user, email).deliver_later
    end

    # Always the same answer, so this page cannot be used to probe for known addresses.
    redirect_to new_user_session_path,
                notice: 'Si cette adresse est connue, un lien de connexion vient de vous être envoyé.'
  end

  private

  def users_reachable_at(email)
    return User.none if email.blank?

    User.where(email:).or(User.where(id: UserContactEmail.where(email:).select(:user_id)))
  end
end
