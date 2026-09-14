# frozen_string_literal: true

class FfhbSyncJob < ApplicationJob
  def perform
    Championship.where(season: Season.current).where.not(ffhb_key: nil).map(&:async_ffhb_sync!)
  end
end
