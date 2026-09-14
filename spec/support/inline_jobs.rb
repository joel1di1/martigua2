# frozen_string_literal: true

# Runs jobs synchronously by swapping the global queue adapter for the
# :inline one. Unlike `perform_enqueued_jobs` blocks (which rely on the :test
# adapter, thread-local), this affects every Thread — required for feature
# specs whose requests are handled by a real Puma server on another Thread.
module InlineJobs
  def run_jobs_inline
    previous_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
    yield
  ensure
    ActiveJob::Base.queue_adapter = previous_adapter
  end
end

RSpec.configure do |config|
  config.include InlineJobs
end
