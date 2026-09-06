# frozen_string_literal: true

require 'rails_helper'

# Guards the invariant established by the ConvertTimestampsToUtc migration: timestamps are
# STORED in UTC and RENDERED in Paris. Before that migration the app ran with
# `config.active_record.default_timezone = :local`, which stored Paris wall-clock time and
# made the stored value depend on the host's system timezone.
# rubocop:disable-next RSpec/DescribeClass -- an app-wide storage invariant, not one class
RSpec.describe 'Timestamp time zone handling' do
  # A winter date (CET, UTC+1) and a summer date (CEST, UTC+2). A conversion built on a
  # fixed offset passes one of these and fails the other.
  let(:cet_local) { '2025-01-15 20:30:00' }
  let(:cest_local) { '2025-07-15 20:30:00' }

  def stored_start_datetime(match)
    ActiveRecord::Base.connection
                      .select_value("SELECT start_datetime FROM matches WHERE id = #{match.id}")
                      .strftime('%Y-%m-%d %H:%M:%S')
  end

  it 'is configured to store timestamps in UTC' do
    expect(ActiveRecord.default_timezone).to eq(:utc)
    expect(Time.zone.name).to eq('Paris')
  end

  describe 'round-tripping through save/reload' do
    it 'preserves the wall-clock time of a CET (winter, UTC+1) date' do
      expected = Time.zone.parse(cet_local)
      match = create(:match, start_datetime: expected)

      match.reload

      expect(match.start_datetime).to eq(expected)
      expect(match.start_datetime.strftime('%Y-%m-%d %H:%M:%S')).to eq(cet_local)
    end

    it 'preserves the wall-clock time of a CEST (summer, UTC+2) date' do
      expected = Time.zone.parse(cest_local)
      match = create(:match, start_datetime: expected)

      match.reload

      expect(match.start_datetime).to eq(expected)
      expect(match.start_datetime.strftime('%Y-%m-%d %H:%M:%S')).to eq(cest_local)
    end
  end

  describe 'what is actually written to the column' do
    it 'stores a CET time shifted back by one hour' do
      match = create(:match, start_datetime: Time.zone.parse(cet_local))

      expect(stored_start_datetime(match)).to eq('2025-01-15 19:30:00')
    end

    it 'stores a CEST time shifted back by two hours' do
      match = create(:match, start_datetime: Time.zone.parse(cest_local))

      expect(stored_start_datetime(match)).to eq('2025-07-15 18:30:00')
    end
  end

  describe 'trainings' do
    it 'preserves wall-clock times across the autumn DST transition' do
      # 2025-10-26: 03:00 CEST becomes 02:00 CET. These two trainings are 90 minutes apart
      # in local terms but three hours apart as instants.
      before_transition = Time.zone.parse('2025-10-26 01:30:00')
      after_transition  = Time.zone.parse('2025-10-26 04:00:00')

      early = create(:training, start_datetime: before_transition, end_datetime: after_transition)
      early.reload

      expect(early.start_datetime.strftime('%Y-%m-%d %H:%M')).to eq('2025-10-26 01:30')
      expect(early.end_datetime.strftime('%Y-%m-%d %H:%M')).to eq('2025-10-26 04:00')
      expect(early.start_datetime.utc_offset).to eq(2 * 3600) # CEST
      expect(early.end_datetime.utc_offset).to eq(1 * 3600)   # CET
    end
  end

  describe 'querying' do
    it 'finds a CEST record by a Paris-local range' do
      match = create(:match, start_datetime: Time.zone.parse(cest_local))
      range = Time.zone.parse('2025-07-15 00:00:00')..Time.zone.parse('2025-07-15 23:59:59')

      expect(Match.where(start_datetime: range)).to include(match)
    end

    it 'finds a CET record by a Paris-local range' do
      match = create(:match, start_datetime: Time.zone.parse(cet_local))
      range = Time.zone.parse('2025-01-15 00:00:00')..Time.zone.parse('2025-01-15 23:59:59')

      expect(Match.where(start_datetime: range)).to include(match)
    end
  end
end
