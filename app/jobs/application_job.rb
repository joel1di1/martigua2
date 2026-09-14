# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encounter common transient failures.
  # retry_on ActiveRecord::Deadlocked

  # Discard failed jobs that have been attempted several times (default is 5).
  # discard_on ActiveJob::PermanentRetryFailure
end
