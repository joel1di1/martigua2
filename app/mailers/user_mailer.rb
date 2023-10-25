# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: 'admin@martigua.org'

  def send_training_invitation(trainings, user)
    @trainings = [*trainings]
    @user = user
    training_dates = @trainings.map { |training| training.start_datetime.strftime('%-d/%-m') }.join(', ')
    mail to: user.email, subject: "Entrainement(s) le(s) #{training_dates}"
  end

  def send_match_invitation(matches, user)
    @matches = [*matches]
    @user = user
    match_dates = @matches.map { |match| match.start_datetime.strftime('%-d/%-m') }.join(', ')
    mail to: user.email, subject: "Matches : #{match_dates}"
  end

  def send_tig_mail_for_training(training, next_training_duties, cc = nil)
    @next_training_duties = next_training_duties
    @training = training
    @user = next_training_duties.first

    subject = "Chasubles, c'est ton tour : (#{training.start_datetime.strftime('%-d/%-m')})"
    ccs = next_training_duties[1..].map(&:email)
    mail to: @user.email, cc: ccs + [*cc], subject:
  end

  def send_section_addition_to_existing_user(user, inviter, section)
    @user = user
    @inviter = inviter
    @section = section
    mail to: user.email, subject: "#{inviter.full_name} t'a ajouté dans la section #{section.name} de #{section.club.name}"
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
