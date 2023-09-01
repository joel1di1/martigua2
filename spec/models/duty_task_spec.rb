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
      Timecop.freeze(Time.zone.local(Time.zone.today.year, 12, 1)) do
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

  describe '#set_name_weight_from_key' do
    let(:duty_key) { :mark_table }
    let(:duty_task) { create(:duty_task, key: duty_key) }

    it 'sets the name and weight from the key' do
      expect(duty_task.name).to eq('Faire la table')
      expect(duty_task.weight).to eq(6)
    end

    context 'with a key that does not exist' do
      let(:duty_key) { :not_existing_key }

      it { expect { duty_task }.to raise_error('No details for duty task not_existing_key') }
    end
  end
end
