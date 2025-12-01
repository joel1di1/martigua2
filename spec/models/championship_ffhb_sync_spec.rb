# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Championship do
  describe '.ffhb_sync!' do
    before { mock_ffhb }

    let(:type_competition) { 'D' }
    let(:code_comite) { 94 }
    let(:code_competition) { '16-ans-m-2-eme-division-territoriale-94-75-23229' }
    let(:phase_id) { '41894' }
    let(:code_pool) { '128335' }
    let(:linked_calendar) { nil }

    let(:section) { create(:section) }
    let(:my_team) { create(:team, with_section: section) }
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

    context 'when new matches are added to the championship' do
      it 'creates new matches during sync' do
        # Create championship with only one match initially
        championship.matches.destroy_all
        championship.matches.create!(
          local_team: my_team,
          visitor_team: create(:team),
          day: championship.calendar.days.first,
          ffhb_key: '16-ans-m-2-eme-division-territoriale-94-75-23229 128335 1891863'
        )
        championship.reload
        expect(championship.matches.size).to eq(1)

        # Sync should detect and add the 21 missing matches
        championship.ffhb_sync!

        championship.reload
        expect(championship.matches.size).to eq(22)
      end

      it 'does not create duplicate matches' do
        expect(championship.matches.size).to eq(22)

        # Run sync twice - should not create duplicates
        championship.ffhb_sync!
        championship.reload
        expect(championship.matches.size).to eq(22)

        championship.ffhb_sync!
        championship.reload
        expect(championship.matches.size).to eq(22)
      end
    end
  end

  describe '#stats_sync!' do
    let(:championship) { create(:championship) }
    let(:ffhb_service) { instance_double(FfhbService) }
    let(:stats_json) do
      {
        'rowsData' => [
          {
            'individuId' => 1,
            'matchCount' => 10,
            'totalButs' => 5,
            'totalArrets' => 3,
            'prenom' => 'John',
            'nom' => 'Doe'
          }
        ]
      }
    end

    before do
      allow(FfhbService).to receive(:instance).and_return(ffhb_service)
      allow(ffhb_service).to receive(:fetch_competition_stats).and_return(stats_json)
    end

    it 'creates a new UserChampionshipStat record' do
      expect do
        championship.stats_sync!(1, 1, 1)
      end.to change(UserChampionshipStat, :count).by(1)
    end

    it 'updates an existing UserChampionshipStat record' do
      user_stat = create(:user_championship_stat, championship:, player_id: 1)

      championship.stats_sync!(1, 1, 1)

      user_stat.reload
      expect(user_stat.match_played).to eq(10)
      expect(user_stat.goals).to eq(5)
      expect(user_stat.saves).to eq(3)
      expect(user_stat.first_name).to eq('John')
      expect(user_stat.last_name).to eq('Doe')
    end
  end
end
