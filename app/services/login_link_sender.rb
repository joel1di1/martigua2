# frozen_string_literal: true

# Mails a sign-in link to an address, once per player it can answer for: the player
# themself, or every player that lists the address as a relative's contact email.
class LoginLinkSender
  def self.call(email)
    new(email).call
  end

  def initialize(email)
    @email = email.to_s.strip.downcase
  end

  def call
    users = reachable_users.to_a
    users.each { |user| UserMailer.send_login_link(user, @email).deliver_later }
    UserContactEmail.where(email: @email, user: users).update_all(last_link_sent_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    users
  end

  # True when a password attempt with this address cannot succeed, so a link is the only way in:
  # it belongs to relatives only, or to a player who never chose a password.
  def passwordless?
    return false if @email.blank?

    main_users = User.where(email: @email)
    return reachable_users.exists? if main_users.none?

    main_users.all? { |user| user.invited_to_sign_up? || user.encrypted_password.blank? }
  end

  def reachable_users
    return User.none if @email.blank?

    User.where(email: @email).or(User.where(id: UserContactEmail.where(email: @email).select(:user_id)))
  end
end
