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

  desc 'Send a test email to check the provider configuration: rake mails:test_config[you@example.com]'
  task :test_config, [:recipient] => :environment do |_task, args|
    recipient = args[:recipient] || ENV.fetch('RECIPIENT', nil)
    raise ArgumentError, 'usage: rake mails:test_config[you@example.com]' if recipient.blank?

    puts "environment      : #{Rails.env}"
    puts "delivery method  : #{Rails.application.config.action_mailer.delivery_method}"
    puts "SCW_PROJECT_ID   : #{ENV.fetch('SCW_PROJECT_ID', nil).presence || '(MISSING)'}"
    puts "SCW_SECRET_KEY   : #{ENV.fetch('SCW_SECRET_KEY', nil).present? ? '(set)' : '(MISSING)'}"
    puts "SCW_REGION       : #{ENV.fetch('SCW_REGION', Scaleway::TransactionalEmailDelivery::DEFAULT_REGION)}"

    SystemMailer.configuration_test(recipient).deliver_now
    puts "\nsent to #{recipient}"
  end
end
