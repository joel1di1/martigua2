# frozen_string_literal: true

RSpec.describe FfhbService do
  let(:ffhb_instance) { FfhbService.instance }

  before { mock_ffhb }

  describe '#get_pool_as_json' do
    subject(:pool_as_json) { ffhb_instance.get_pool_as_json(110_562) }

    it { expect(pool_as_json).to be_a(Hash) }
    it { expect(pool_as_json['journee']).to be(5) }

    it { expect { ffhb_instance.get_pool_as_json(123) }.to raise_error(RuntimeError, 'Could not find pool with id 123') }
  end

  describe '#build_specific_calendar' do
    subject(:calendar) do
      ffhb_instance.build_specific_calendar(ffhb_instance.get_pool_as_json(110_562), 'test name', {}, []).first
    end

    it { expect(calendar).to be_a(Calendar) }
    it { expect(calendar.days.size).to be(22) }
    it { expect(calendar.days[1]).to be_a(Day) }
    it { expect(calendar.days[1].name).to eq('Journée #2 (1 oct. - 2 oct.)') }
    it { expect(calendar.days[19].name).to eq('Journée #20 (13 mai - 14 mai)') }
    it { expect(calendar.days[1].period_start_date).to eq(Date.new(2022, 10, 1)) }
    it { expect(calendar.days[1].period_end_date).to eq(Date.new(2022, 10, 2)) }
  end

  describe '#build_championship' do
    subject(:championship) do
      ffhb_instance.build_championship(code_pool:, code_division:, code_comite:, type_competition:, team_links:)
    end

    let(:type_competition) { 'D' }
    let(:code_comite) { 'C44' }
    let(:code_division) { 20_570 }
    let(:code_pool) { 110_562 }
    let(:team_links) { {} }
    let(:expected_name) { "#{Season.current.name}-#{type_competition}-#{code_comite}-#{code_division}-#{code_pool}" }

    it { expect { championship }.not_to change(Championship, :count) }
    it { expect { championship }.not_to change(Calendar, :count) }
    it { expect { championship }.not_to change(Day, :count) }
    it { expect { championship }.not_to change(Team, :count) }

    it { expect(championship.name).to eq 'COMITE DE LOIRE ATLANTIQUE - 2EME DTM 44' }
    it { expect(championship.ffhb_key).to eq expected_name }

    it { expect(championship.enrolled_team_championships.size).to eq(12) }
    it { expect(championship.calendar.days.size).to eq(22) }

    context 'with incorrect pool code' do
      let(:code_pool) { 123 }

      it do
        expect { championship }.to raise_error(RuntimeError, 'Could not find pool with id 123')
      end
    end

    context 'with team links' do
      let(:my_team) { create(:team) }
      let(:team_links) { { 'VERTOU HANDBALL 1' => my_team.id } }

      it { expect(championship.matches.size).to eq 22 }

      describe 'teams' do
        subject(:enrolled_teams) { championship.enrolled_team_championships }

        let(:championship) { ffhb_instance.build_championship(code_pool:, code_division:, code_comite:, type_competition:, team_links:) }

        it { expect(enrolled_teams.map(&:team)).to include(my_team) }
        it { expect(enrolled_teams.find { |etc| etc.team == my_team }.enrolled_name).to eq 'VERTOU HANDBALL 1' }
      end
    end
  end
end
