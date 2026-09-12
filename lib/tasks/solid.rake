# frozen_string_literal: true

# Smoke test for the Redis -> Solid gems migration (issue #1191).
# Adapter-agnostic: run it before the migration (Sidekiq + Redis baseline) and after
# (`heroku run rake solid:check` on production, or locally), and compare.
#
#   rake solid:check
#
# ActionCable / Solid Cable is intentionally not covered: test manually by opening the
# chat feature in two browsers and confirming the broadcast from the Message model.
# rubocop:disable-next Metrics/BlockLength
namespace :solid do
  desc 'Smoke test the background stack: cache store, queue adapter, async job and email delivery'
  task check: :environment do
    puts "Rails version:   #{Rails.version}"
    puts "Cache store:     #{Rails.cache.class}"
    puts "Queue adapter:   #{ActiveJob::Base.queue_adapter.class}"

    # --- cache write/read -------------------------------------------------------------
    key = 'solid:check'
    value = "written at #{Time.current}"
    Rails.cache.write(key, value)
    read_back = Rails.cache.read(key)
    puts "Cache write/read: #{read_back == value ? 'OK' : "FAIL (read back #{read_back.inspect})"}"
    puts '  (NullStore: run `bin/rails dev:cache` to enable caching in development)' if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)

    # --- async email to user 1 ----------------------------------------------------------
    user = User.find(1)
    user.async_send_solid_check_email
    puts "Enqueued ActiveRecordAsyncJob for #{user.email} (user 1)"

    if defined?(SolidQueue)
      # Poll until the job has been picked up and executed by a worker. If it stays
      # pending, no worker is running: in development, `bin/rails solid_queue:start`
      # (or bin/dev, which runs Puma with the Solid Queue plugin); in production, the
      # web dyno must have SOLID_QUEUE_IN_PUMA=1.
      deadline = 30.seconds.from_now
      finished = false
      while Time.current < deadline && !finished
        finished = SolidQueue::Job.where(class_name: 'ActiveRecordAsyncJob', finished_at: 1.minute.ago..)
                                  .exists?(['created_at > ?', 1.minute.ago])
        break if finished

        sleep 1
      end
      puts "Async job:        #{finished ? 'finished' : 'still pending after 30s'}"
      if finished
        puts 'Last step:        check user 1 inbox to confirm the delivery provider path ' \
             '(BlockedAddress filtering must not apply to user 1)'
      else
        puts '  still pending => no worker is running (dev: bin/rails solid_queue:start; ' \
             'production: SOLID_QUEUE_IN_PUMA=1 on the web dyno)'
      end
    else
      puts 'Async job:        not pollable outside Solid Queue — check the worker/Sidekiq Web UI'
    end
  end
end
