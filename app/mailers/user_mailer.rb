# frozen_string_literal: true

class UserMailer < ActionMailer::Base
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

  def send_tig_mail_for_training(training, next_training_duties)
    @next_training_duties = next_training_duties
    @training = training
    @user = next_training_duties.first

    subject = "Chasubles, c'est ton tour : (#{training.start_datetime.strftime('%-d/%-m')})"
    ccs = next_training_duties[1..-1].map(&:email) + ['guillaume.pech@gmail.com']
    mail to: @user.email, cc: ccs, subject:
  end
end
