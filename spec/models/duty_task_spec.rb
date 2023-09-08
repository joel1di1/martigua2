# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DutyTask do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :club }
  it { is_expected.to validate_presence_of :name }

  describe '.for_current_season' do
    it 'returns duty tasks for the current season' do
      Timecop.freeze(Time.zone.local(Time.zone.today.year, 12, 1)) do
        # Create duty tasks for the current season
        current_season_tasks = [
          create(:duty_task, realised_at: Season.current.start_date + 1.day),
          create(:duty_task, realised_at: Season.current.start_date + 1.month),
          create(:duty_task, realised_at: Season.current.end_date - 1.month),
          create(:duty_task, realised_at: Season.current.end_date)
        ]

        # Create duty tasks for other seasons
        other_season_tasks = [
          create(:duty_task, realised_at: Season.current.start_date - 1.month),
          create(:duty_task, realised_at: Season.current.end_date + 1.month)
        ]

        # Call the scope and check if it returns the correct records
        expect(DutyTask.for_current_season.order(:realised_at).pluck(:id)).to match_array(current_season_tasks.map(&:id))
        expect(DutyTask.for_current_season.order(:realised_at).pluck(:id)).not_to match_array(other_season_tasks.map(&:id))
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
