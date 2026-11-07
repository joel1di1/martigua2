# frozen_string_literal: true

RSpec.describe FfhbService do
  let(:ffhb_instance) { FfhbService.instance }

  describe '#fetch_smartfire_attributes' do
    let(:url) { 'https://example.com/test' }
    let(:attribute_name) { 'test-component' }

    context 'when smartfire component is not found' do
      before do
        allow(ffhb_instance).to receive(:http_get_with_cache).and_return('<html><body>No component here</body></html>')
      end

      it 'raises FfhbServiceError with descriptive message' do
        expect do
          ffhb_instance.fetch_smartfire_attributes(url, attribute_name)
        end.to raise_error(FfhbServiceError, /Smartfire component 'test-component' not found/)
      end
    end

    context 'when smartfire component exists but has no attributes' do
      before do
        html = '<html><body><smartfire-component name="test-component"></smartfire-component></body></html>'
        allow(ffhb_instance).to receive(:http_get_with_cache).and_return(html)
      end

      it 'raises FfhbServiceError with descriptive message' do
        expect do
          ffhb_instance.fetch_smartfire_attributes(url, attribute_name)
        end.to raise_error(FfhbServiceError, /Attributes not found for component/)
      end
    end
  end

  describe 'real calls to ffhb' do
    describe '#fetch_comite_details' do
      subject(:comite_details) { ffhb_instance.fetch_comite_details(comite_id) }

      let(:comite_id) { 94 }

      it 'is correct structure' do # one it to reduce calls
        expect(comite_details).to be_a(Hash)
        expect(comite_details['url_competition_type']).to eq 'departemental'
        expect(comite_details['url_structure']).to eq 'comite-du-val-de-marne-124'
        expect(comite_details['structure']['libelle']).to eq 'COMITE DU VAL-DE-MARNE'
      end
    end
  end

  describe 'mocked' do
    before { mock_ffhb }

    let(:type_competition) { 'D' }
    let(:code_comite) { 94 }
    let(:code_competition) { '16-ans-m-2-eme-division-territoriale-94-75-23229' }
    let(:phase_id) { '41894' }
    let(:code_pool) { '128335' }
    let(:team_links) { {} }
    let(:linked_calendar) { nil }

    describe '#build_specific_calendar' do
      subject(:calendar) do
        ffhb_instance.build_specific_calendar(
          ffhb_instance.fetch_pool_details(code_competition, code_pool),
          'test name', {}, [], linked_calendar
        ).first
      end

      it { expect(calendar).to be_a(Calendar) }
      it { expect { calendar }.not_to change(Day, :count) }
      it { expect(calendar.days.size).to be(22) }
      it { expect(calendar.days[1]).to be_a(Day) }
      it { expect(calendar.days[1].name).to eq('WE du 22 sept. au 24 sept.') }
      it { expect(calendar.days[19].name).to eq('WE du 24 mai au 26 mai') }
      it { expect(calendar.days[1].period_start_date).to eq(Date.new(2023, 9, 18)) }
      it { expect(calendar.days[1].period_end_date).to eq(Date.new(2023, 9, 24)) }

      context 'with a linked calendar' do
        let!(:linked_calendar) { create(:calendar, name: "Championnat #{Season.current}") }
        let!(:existing_day) { create(:day, calendar: linked_calendar, name: 'WE du 24 sept. au 25 sept') }

        it { expect(calendar).to eq linked_calendar }
        it { expect(calendar.name).to eq "Championnat #{Season.current}" }
        it { expect(calendar.days).to include existing_day }
      end
    end

    describe '#build_championship' do
      subject(:championship) do
        ffhb_instance.build_championship(type_competition:, code_comite:, code_competition:, phase_id:, code_pool:,
                                         team_links:, linked_calendar:)
      end

      it { expect { championship }.not_to change(Championship, :count) }
      it { expect { championship }.not_to change(Calendar, :count) }
      it { expect { championship }.not_to change(Day, :count) }
      it { expect { championship }.not_to change(Team, :count) }

      it { expect(championship.name).to eq 'COMITE DU VAL-DE-MARNE - +16 ANS M 2 EME DIVISION TERRITORIALE 94 & 75' }

      it {
        expect(championship.ffhb_key).to eq '2023-2024-19 departemental 16-ans-m-2-eme-division-territoriale-94-75-23229 41894 128335'
      }

      it { expect(championship.enrolled_team_championships.size).to eq(12) }
      it { expect(championship.calendar.days.size).to eq(22) }

      context 'with team links' do
        let(:my_team) { create(:team) }
        let(:team_links) { { '1589702' => my_team.id.to_s } }

        describe 'teams' do
          subject(:enrolled_teams) { championship.enrolled_team_championships }

          let(:championship) do
            ffhb_instance.build_championship(type_competition:, code_comite:, code_competition:, phase_id:, code_pool:,
                                             team_links:, linked_calendar:)
          end

          it { expect(enrolled_teams.map(&:team)).to include(my_team) }
          it { expect(enrolled_teams.find { |etc| etc.team == my_team }.enrolled_name).to eq 'MARTIGUA SCL' }

          it { expect(championship.matches.size).to eq(22) }

          it {
            expect(championship.matches.first.ffhb_key).to eq('16-ans-m-2-eme-division-territoriale-94-75-23229 128335 1891863')
          }
        end
      end
    end
  end
end
