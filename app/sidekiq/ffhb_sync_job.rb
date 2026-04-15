# frozen_string_literal: true

class FfhbSyncJob
  include Sidekiq::Job

  sidekiq_options queue: :default

  def perform
    Championship.where(season: Season.current).where.not(ffhb_key: nil).map(&:async_ffhb_sync!)
  end
end
