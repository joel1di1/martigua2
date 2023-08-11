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
    let(:code_comite) { 'C44' }
    let(:code_division) { 20_570 }
    let(:code_pool) { 110_562 }
    let(:team_links) { {} }

    describe '#ffhb_sync!' do
      let(:my_team) { create(:team) }
      let(:team_links) { { 'VERTOU HANDBALL 1' => my_team.id } }
      let(:championship) do
        Championship.create_from_ffhb!(code_pool:, code_division:, code_comite:, type_competition:, team_links:)
      end

      it 'updates matches with start_datetime, location and score' do
        landreau_vertou = championship.matches.find_by(visitor_team: my_team, day: Day.find_by(name: 'WE du 24 sept. au 25 sept.'))
        expect(landreau_vertou.start_datetime).to be_nil
        expect(landreau_vertou.local_score).to be_nil
        expect(landreau_vertou.visitor_score).to be_nil

        championship.ffhb_sync!

        landreau_vertou.reload
        expect(landreau_vertou.start_datetime).to eq(Time.zone.local(2022, 9, 24, 21, 30, 0))
        expect(landreau_vertou.local_score).to eq(33)
        expect(landreau_vertou.visitor_score).to eq(30)
        expect(landreau_vertou.location.address).to eq("SALLE DES NOUELLES\n19  RUE DE LA LOIRE\nLE LANDREAU")
      end

      # rubocop:disable RSpec/MultipleMemoizedHelpers
      describe 'updates user championship stats' do
        let(:alexis) { create(:user, with_section: section) }
        let(:clement) { create(:user, with_section: section) }
        let(:lower_championship) { create(:championship, season: Season.current, name: 'COMITE DE LOIRE ATLANTIQUE - 3EME DTM 44') }

        before do
          UserChampionshipStat.create!(user: alexis, championship:, player_id: '6244093100969')
          UserChampionshipStat.create!(user: alexis, championship: lower_championship, player_id: '6244093100969')
          UserChampionshipStat.create!(user: clement, championship:, player_id: '6244093100892')
          group = ChampionshipGroup.create!
          group.add_championship(championship, index: 1)
          group.add_championship(lower_championship, index: 2)
        end

        it 'updates burned players in lower championship' do
          expect { championship.ffhb_sync! }.to change { lower_championship.reload.burned?(alexis) }.from(false).to(true)
        end

        it 'keep player untouched for championship where he played' do
          expect { championship.ffhb_sync! }.not_to(change { championship.reload.burned?(alexis) })
        end
      end
      # rubocop:enable RSpec/MultipleMemoizedHelpers
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
end
