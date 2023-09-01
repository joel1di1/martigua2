# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DutyTask do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :club }
  it { is_expected.to validate_presence_of :name }

  describe '.for_current_season' do
    let(:current_season_start) { Date.new(Time.zone.today.year, 8, 1) }
    let(:current_season_end) { Date.new(Time.zone.today.year + 1, 6, 30) }

    it 'returns duty tasks for the current season' do
      # Create duty tasks for the current season
      current_season_tasks = [
        create(:duty_task, realised_at: current_season_start),
        create(:duty_task, realised_at: current_season_end),
        create(:duty_task, realised_at: current_season_start + 1.month),
        create(:duty_task, realised_at: current_season_end - 1.month)
      ]

      # Create duty tasks for other seasons

      # Call the scope and check if it returns the correct records
      expect(DutyTask.for_current_season).to match_array(current_season_tasks)
    end
  end
end
