# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Championship do
  let(:championship) { create(:championship) }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to belong_to :season }
  it { is_expected.to belong_to :calendar }
  it { is_expected.to have_many :teams }
  it { is_expected.to have_many :matches }
  it { is_expected.to have_many :burns }

  describe '.enroll_team!' do
    subject { championship.enroll_team!(team) }

    let(:team) { create(:team) }

    context 'with new team' do
      it { expect(subject.enrolled_teams).to match_array([team]) }
    end

    context 'with already enrolled team' do
      before { championship.enroll_team!(team) }

      it { expect(subject.enrolled_teams).to match_array([team]) }
    end
  end

  describe '#unenroll_team!' do
    subject { championship.unenroll_team!(team) }

    let(:team) { create(:team) }

    context 'with new team' do
      it { expect(subject.enrolled_teams).to match_array([]) }
    end

    context 'with already enrolled team' do
      before { championship.enroll_team!(team) }

      it { expect(subject.enrolled_teams).to match_array([]) }
    end
  end

  describe 'sync ffhb' do
    before { mock_ffhb }

    let(:type_competition) { 'D' }
    let(:code_comite) { 'C44' }
    let(:code_division) { 20_570 }
    let(:code_pool) { 110_562 }
    let(:team_links) { {} }

    describe '.create_from_ffhb!' do
      subject(:create_championship) do
        Championship.create_from_ffhb!(code_pool:, code_division:, code_comite:, type_competition:, team_links:)
      end

      let(:expected_name) { "#{Season.current.name}-#{type_competition}-#{code_comite}-#{code_division}-#{code_pool}" }

      it { expect { create_championship }.to change(Championship, :count).by(1) }
      it { expect { create_championship }.to change(Calendar, :count).by(1) }
      it { expect(create_championship.name).to eq 'COMITE DE LOIRE ATLANTIQUE - 2EME DTM 44' }
      it { expect(create_championship.ffhb_key).to eq expected_name }
      it { expect { create_championship }.to change(Day, :count).by(22) }
      it { expect { create_championship }.to change(Team, :count).by(12) }

      context 'with team links' do
        let!(:my_team) { create(:team) }
        let(:team_links) { { 'VERTOU HANDBALL 1' => my_team.id } }

        it { expect { create_championship }.to change(Match, :count).by 22 }
        it { expect { create_championship }.to change(Team, :count).by 11 }
      end

      context 'with incorrect pool code' do
        let(:code_pool) { 123 }

        it do
          expect { create_championship }.to raise_error(RuntimeError, 'Could not find pool with id 123')
        end
      end
    end

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
    end
  end

  describe '.burned_players' do
    let(:section) { create :section }
    let!(:team) { create :team, with_section: section, enrolled_in: championship }
    let!(:player1) { create :user, with_section: section }
    let!(:player2) { create :user, with_section: section }
    let!(:player3) { create :user, with_section: section }

    before do
      championship.burn!(player1)
      championship.burn!(player2)
      championship.burn!(player3)
      championship.unburn!(player2)
    end

    it { expect(championship.burned_players.to_a).to eq([player1, player3]) }
  end
end
