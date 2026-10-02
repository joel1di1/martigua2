# frozen_string_literal: true

# Lets someone who receives a player's mails — typically a parent on the player's contact
# emails — ask for a fresh sign-in link between two invitation mails.
class LoginLinksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_user_member_of_section

  rate_limit to: 5, within: 1.minute, only: :create

  def new; end

  def create
    LoginLinkSender.call(params[:email])

    # Always the same answer, so this page cannot be used to probe for known addresses.
    redirect_to new_user_session_path,
                notice: 'Si cette adresse est connue, un lien de connexion vient de vous être envoyé.'
  end
end
