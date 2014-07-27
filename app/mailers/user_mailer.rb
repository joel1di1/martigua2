class UserMailer < ActionMailer::Base
  default from: "admin@martigua.org"

  def send_training_invitation(training, user)
    @training = training
    @user = user
    mail to: user.email, subject: "Invitation à l'entrainement"
  end
end
