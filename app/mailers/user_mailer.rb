# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: 'admin@martigua.org'

  def send_training_invitation(trainings, user)
    @trainings = [*trainings]
    @user = user
    training_dates = @trainings.map { |training| training.start_datetime.strftime('%-d/%-m') }.join(', ')
    mail to: user.email, cc: user.contact_email_addresses.presence, subject: "Entrainement(s) le(s) #{training_dates}"
  end

  def send_match_invitation(matches, user)
    @matches = [*matches]
    @user = user
    match_dates = @matches.map { |match| match.start_datetime.strftime('%-d/%-m') }.join(', ')
    mail to: user.email, cc: user.contact_email_addresses.presence, subject: "Matches : #{match_dates}"
  end

  def send_section_addition_to_existing_user(user, inviter, section)
    @user = user
    @inviter = inviter
    @section = section
    mail to: user.email,
         cc: user.contact_email_addresses.presence,
         subject: "#{inviter.full_name} t'a ajouté dans la section #{section.name} de #{section.club.name}"
  end

  def send_login_link(user, recipient)
    @user = user
    @token = user.generate_token_for(:email_authentication)
    mail to: recipient, subject: "Ton lien de connexion pour répondre pour #{user.full_name}"
  end

  # Sent to a relative's address the moment it is added, so they learn the club writes to
  # them and that they can answer for the player without an account of their own.
  def send_contact_email_welcome(user, recipient)
    @user = user
    @token = user.generate_token_for(:email_authentication)
    mail to: recipient, subject: "Tu peux maintenant répondre pour #{user.full_name}"
  end

  # TODO: factorize method missing with ApplicationRecord
  def self.method_missing(method, *, &block)
    if method.to_s.start_with?('async_')
      raise 'async jobs with block are not supported' if block.present?

      ActiveRecordAsyncJob.perform_async(name, nil, method.to_s.sub('async_', ''), *)
    else
      super
    end
  end

  def self.respond_to_missing?(method, include_private = false)
    method.to_s.start_with?('async_') || super
  end
end
