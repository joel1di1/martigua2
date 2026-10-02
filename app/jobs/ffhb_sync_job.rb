# frozen_string_literal: true

class FfhbSyncJob < ApplicationJob
  def perform
    championship_ids = Championship.where(season: Season.current).where.not(ffhb_key: nil).pluck(:id)

    # One bulk insert into the queue instead of one INSERT per championship
    # (avoids Sentry's N+1 detection on solid_queue_jobs).
    ActiveJob.perform_all_later(
      championship_ids.map { |id| ActiveRecordAsyncJob.new('Championship', id, 'ffhb_sync!') }
    )
  end
end
