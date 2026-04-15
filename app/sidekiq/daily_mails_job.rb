# frozen_string_literal: true

class DailyMailsJob
  include Sidekiq::Job

  sidekiq_options queue: :default

  def perform
    today = Time.zone.today
    case today.cwday
    when 1
      Match.async_send_availability_mail_for_next_weekend
    when 6
      Training.async_send_presence_mail_for_next_week
    end
    Training.async_send_tig_mail_for_next_training
  end
end
