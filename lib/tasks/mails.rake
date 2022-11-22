# frozen_string_literal: true

namespace :mails do
  task send_daily_mails: :environment do
    today = Time.zone.today
    case today.cwday
    when 1
      Match.async_send_availability_mail_for_next_weekend
    when 6
      Training.async_send_presence_mail_for_next_week
    end
    Training.async_send_tig_mail_for_next_training
  end

  task send_for_matches: :environment do
    Match.async_send_availability_mail_for_next_weekend
  end

  task send_for_trainings: :environment do
    Training.async_send_presence_mail_for_next_week
  end

  task send_tig_mail_for_next_training: :environment do
    Training.async_send_tig_mail_for_next_training
  end
end
