# frozen_string_literal: true

namespace :mails do
  task send_daily_mails: :environment do
    DailyMailsJob.new.perform
  end

  task send_for_matches: :environment do
    Match.async_send_availability_mail_for_next_weekend
  end

  task send_for_trainings: :environment do
    Training.async_send_presence_mail_for_next_week
  end
end
