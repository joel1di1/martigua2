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

  describe 'sync ffhb' do
    before { mock_ffhb }

    let(:type_competition) { 'D' }
    let(:code_comite) { 94 }
    let(:code_competition) { '16-ans-m-2-eme-division-territoriale-94-75-23229' }
    let(:phase_id) { '41894' }
    let(:code_pool) { '128335' }
    let(:linked_calendar) { nil }

    describe '#ffhb_sync!' do
      let(:my_team) { create(:team) }
      let(:team_links) { { '1589702' => my_team.id } }

      let(:championship) do
        Championship.create_from_ffhb!(type_competition:, code_comite:, code_competition:, phase_id:, code_pool:,
                                       team_links:, linked_calendar:)
      end

      it 'updates matches with start_datetime, location and score' do
        expect(championship.matches.size).to eq(22)

        expect(championship.matches).to all(receive(:ffhb_sync!))

        championship.ffhb_sync!
      end

      #   describe 'updates user championship stats' do
      #     let(:alexis) { create(:user, with_section: section) }
      #     let(:clement) { create(:user, with_section: section) }
      #     let(:lower_championship) { create(:championship, season: Season.current, name: 'COMITE DE LOIRE ATLANTIQUE - 3EME DTM 44') }

      #     before do
      #       UserChampionshipStat.create!(user: alexis, championship:, player_id: '6244093100969')
      #       UserChampionshipStat.create!(user: alexis, championship: lower_championship, player_id: '6244093100969')
      #       UserChampionshipStat.create!(user: clement, championship:, player_id: '6244093100892')
      #       group = ChampionshipGroup.create!
      #       group.add_championship(championship, index: 1)
      #       group.add_championship(lower_championship, index: 2)
      #     end

      #     it 'updates burned players in lower championship' do
      #       expect { championship.ffhb_sync! }.to change { lower_championship.reload.burned?(alexis) }.from(false).to(true)
      #     end

      #     it 'keep player untouched for championship where he played' do
      #       expect { championship.ffhb_sync! }.not_to(change { championship.reload.burned?(alexis) })
      #     end
      #   end
      #
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
