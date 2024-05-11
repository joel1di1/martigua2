# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Championship do
  let(:championship) { create(:championship) }
  let(:section) { create(:section) }
  let(:team) { create(:team, with_section: section) }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to belong_to :season }
  it { is_expected.to belong_to :calendar }
  it { is_expected.to have_many :teams }
  it { is_expected.to have_many :matches }
  it { is_expected.to have_many :burns }

  describe '.enroll_team!' do
    subject { championship.enroll_team!(team) }

    context 'with new team' do
      it { expect(subject.enrolled_teams).to contain_exactly(team) }
    end

    context 'with already enrolled team' do
      before { championship.enroll_team!(team) }

      it { expect(subject.enrolled_teams).to contain_exactly(team) }
    end
  end

  describe '#unenroll_team!' do
    subject { championship.unenroll_team!(team) }

    context 'with new team' do
      it { expect(subject.enrolled_teams).to be_empty }
    end

    context 'with already enrolled team' do
      before { championship.enroll_team!(team) }

      it { expect(subject.enrolled_teams).to be_empty }
    end
  end

  describe '.burned_players' do
    let(:section) { create(:section) }
    let!(:player1) { create(:user, with_section: section) }
    let!(:player2) { create(:user, with_section: section) }
    let!(:player3) { create(:user, with_section: section) }

    before do
      championship.burn!(player1)
      championship.burn!(player2)
      championship.burn!(player3)
      championship.unburn!(player2)
    end

    it { expect(championship.burned_players).to contain_exactly(player1, player3) }
  end

  describe '#find_or_create_day_for' do
    context 'with no existing day' do
      it 'creates a new day' do
        day = championship.find_or_create_day_for(Time.zone.parse('2023-09-16'))
        expect(day).to be_persisted
        expect(day.period_start_date).to eq(Date.parse('2023-09-11'))
        expect(day.period_end_date).to eq(Date.parse('2023-09-18'))
        expect(day.name).to eq('Week 2023-09-11 2023-09-17')
      end
    end
  end
end
