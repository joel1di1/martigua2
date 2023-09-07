# frozen_string_literal: true

namespace :ffhb do
  task sync: :environment do
    Championship.where(season: Season.current).where.not(ffhb_key: nil).map(&:async_ffhb_sync!)
  end
end
