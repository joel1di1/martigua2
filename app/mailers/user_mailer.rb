class UserMailer < ActionMailer::Base
  default from: "admin@martigua.org"

  def send_training_invitation(trainings, user)
    @trainings = [*trainings]
    @user = user
    training_dates = @trainings.map{|training| training.start_datetime.strftime("%-d/%-m")}.join(', ')
    mail to: user.email, subject: "Entrainement(s) le(s) #{training_dates}"
  end
end
