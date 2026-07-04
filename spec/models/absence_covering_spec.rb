# frozen_string_literal: true

require 'rails_helper'

# absences.start_at/end_at are date columns: coverage is date-granular, so being
# absent through the day a match takes place covers it whatever the kick-off time.
RSpec.describe Absence do
  describe '.covering / #covers?' do
    subject(:absence) { create(:absence, start_at:, end_at:) }

    let(:period_start) { Time.zone.parse('2026-09-12 14:00') }
    let(:period_end) { Time.zone.parse('2026-09-12 16:00') }

    context 'when the absence spans the whole period' do
      let(:start_at) { Date.parse('2026-09-11') }
      let(:end_at) { Date.parse('2026-09-14') }

      it { expect(absence.covers?(period_start, period_end)).to be true }
      it { expect(Absence.covering(period_start, period_end)).to include(absence) }
    end

    context 'when the absence starts on the day of the period' do
      let(:start_at) { Date.parse('2026-09-12') }
      let(:end_at) { Date.parse('2026-09-13') }

      it { expect(absence.covers?(period_start, period_end)).to be true }
      it { expect(Absence.covering(period_start, period_end)).to include(absence) }
    end

    context 'when the absence ends on the day of the period' do
      let(:start_at) { Date.parse('2026-09-10') }
      let(:end_at) { Date.parse('2026-09-12') }

      it { expect(absence.covers?(period_start, period_end)).to be true }
      it { expect(Absence.covering(period_start, period_end)).to include(absence) }
    end

    context 'when the absence starts after the period' do
      let(:start_at) { Date.parse('2026-09-13') }
      let(:end_at) { Date.parse('2026-09-14') }

      it { expect(absence.covers?(period_start, period_end)).to be false }
      it { expect(Absence.covering(period_start, period_end)).not_to include(absence) }
    end

    context 'with a multi-day period, when the absence overlaps the start only' do
      let(:multi_day_end) { Time.zone.parse('2026-09-13 16:00') }
      let(:start_at) { Date.parse('2026-09-10') }
      let(:end_at) { Date.parse('2026-09-12') }

      it { expect(absence.covers?(period_start, multi_day_end)).to be false }
      it { expect(Absence.covering(period_start, multi_day_end)).not_to include(absence) }
    end

    context 'with a multi-day period, when the absence overlaps the end only' do
      let(:multi_day_end) { Time.zone.parse('2026-09-13 16:00') }
      let(:start_at) { Date.parse('2026-09-13') }
      let(:end_at) { Date.parse('2026-09-14') }

      it { expect(absence.covers?(period_start, multi_day_end)).to be false }
      it { expect(Absence.covering(period_start, multi_day_end)).not_to include(absence) }
    end
  end
end
