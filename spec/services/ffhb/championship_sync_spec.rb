# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ffhb::ChampionshipSync do
  describe '#call query counts' do
    before { mock_ffhb }

    let(:section) { create(:section) }
    let(:my_team) { create(:team, with_section: section) }
    let(:championship) do
      Championship.create_from_ffhb!(
        type_competition: 'D', code_comite: 94,
        code_competition: '16-ans-m-2-eme-division-territoriale-94-75-23229',
        phase_id: '41894', code_pool: '128335',
        team_links: { '1589702' => my_team.id }, linked_calendar: nil
      )
    end

    def queries_during(&)
      queries = []
      callback = lambda do |_name, _start, _finish, _id, payload|
        queries << payload[:sql] if payload[:name] != 'SCHEMA'
      end
      ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &)
      queries
    end

    it 'does not load teams one by one for each match' do
      expect(championship.matches.size).to eq(22)

      queries = queries_during { Ffhb::ChampionshipSync.new(championship.reload).call }

      team_lookups = queries.grep(/FROM "teams" WHERE "teams"."id" = \$1 LIMIT/)
      expect(team_lookups.size).to be <= 3
    end

    it 'looks up a venue shared by several matches only once' do
      create(:location, ffhb_id: 'EQUIP1')
      allow(FfhbService.instance).to receive(:fetch_match_details).and_return(
        'rencontre' => { 'date' => nil, 'equipementId' => 'EQUIP1' }
      )
      championship.reload

      queries = queries_during { Ffhb::ChampionshipSync.new(championship).call }

      location_lookups = queries.grep(/FROM "locations" WHERE "locations"."ffhb_id" = \$1 LIMIT/)
      expect(location_lookups.size).to eq(1)
    end
  end
end
