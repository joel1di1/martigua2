# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FfhbSyncJob do
  include ActiveJob::TestHelper

  let(:season) { Season.current }

  before do
    create(:championship, season:, ffhb_key: 'a b c d e')
    create(:championship, season:, ffhb_key: 'f g h i j')
    create(:championship, season:, ffhb_key: nil)
  end

  it 'enqueues one sync job per championship with an ffhb_key' do
    expect { FfhbSyncJob.perform_now }.to have_enqueued_job(ActiveRecordAsyncJob).exactly(2).times
  end

  it 'enqueues the jobs with a single bulk enqueue' do
    expect(ActiveJob).to receive(:perform_all_later).once.and_call_original

    FfhbSyncJob.perform_now
  end

  it 'targets Championship#ffhb_sync!' do
    FfhbSyncJob.perform_now

    expect(ActiveRecordAsyncJob).to have_been_enqueued.with('Championship', anything, 'ffhb_sync!').twice
  end
end
