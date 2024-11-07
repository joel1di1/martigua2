# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Section do
  let(:section) { create(:section) }
  let(:team) { create(:team, with_section: section) }

  describe '#next_events' do
    subject(:next_events) { section.next_events }

    context 'with trainings' do
      let!(:training) { create(:training, with_section: section, start_datetime: 2.days.from_now) }

      it { expect(next_events).to eq [training] }
    end

    context 'with trainings before and after time window' do
      let!(:training) { create(:training, with_section: section, start_datetime: 2.days.ago) }
      let!(:training) { create(:training, with_section: section, start_datetime: 20.days.from_now) }

      it { expect(next_events).to eq [] }
    end

    context 'with matches' do
      let!(:match) { create(:match, local_team: team, start_datetime: 2.days.from_now) }

      it { expect(next_events).to eq [match] }
    end

    context 'with matches before and after time window' do
      let!(:match) { create(:match, local_team: team, start_datetime: 2.days.ago) }
      let!(:match) { create(:match, local_team: team, start_datetime: 20.days.from_now) }

      it { expect(next_events).to eq [] }
    end

    context 'with trainings and matches' do
      let!(:second_training) { create(:training, with_section: section, start_datetime: 3.days.from_now) }
      let!(:first_training) { create(:training, with_section: section, start_datetime: 1.day.from_now) }
      let!(:match) { create(:match, local_team: team, start_datetime: 2.days.from_now) }

      it { expect(next_events).to eq [first_training, match, second_training] }
    end
  end
end
