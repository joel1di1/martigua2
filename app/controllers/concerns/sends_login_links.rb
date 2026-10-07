# frozen_string_literal: true

# For Devise screens that ask for an address and a password: a relative has neither under
# their own address, so rather than a dead end we mail them a sign-in link.
#
# The answer reuses Devise's failure message `devise.failure.invalid`. devise.fr.yml gives it
# and `not_found_in_database` the same wording whether or not the address is known: relatives
# and accounts without a password get a link mailed instead, and the screen must not tell.
module SendsLoginLinks
  extend ActiveSupport::Concern

  private

  def send_login_links_if_passwordless
    sender = LoginLinkSender.new(params.dig(:user, :email))
    return unless sender.passwordless?

    sender.call
    redirect_to new_user_session_path, alert: I18n.t('devise.failure.invalid', authentication_keys: 'Email')
  end
end
