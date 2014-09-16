namespace :mails do

  task :send_daily_mails => :environment do
    today = Date.today
    case today.cwday
    when 2
      Match.delay.send_availability_mail_for_next_week
    when 6
      Training.delay.send_presence_mail_for_next_week
    end

  end

end
