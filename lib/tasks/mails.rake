# frozen_string_literal: true

namespace :mails do
  task send_daily_mails: :environment do
    today = Time.zone.today
    case today.cwday
    when 1
      Match.delay.send_availability_mail_for_next_weekend
    when 6
      Training.delay.send_presence_mail_for_next_week
    end
    Training.delay.send_tig_mail_for_next_training
  end

  task send_for_matches: :environment do
    Match.delay.send_availability_mail_for_next_weekend
  end

  task send_for_trainings: :environment do
    Training.delay.send_presence_mail_for_next_week
  end

  task send_tig_mail_for_next_training: :environment do
    Training.delay.send_tig_mail_for_next_training
  end
end
