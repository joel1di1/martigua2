# frozen_string_literal: true

describe 'Add Match', :devise do
  let(:coach) { create(:coach) }
  let(:team) { coach.sections.first.teams.sample }
  let!(:calendar) { create(:calendar) }
  let(:adversary_team_name) { Faker::Team.name }
  let(:location_name) { Faker::Address.street_name }
  let(:location_address) { Faker::Address.full_address }
  let(:day_name) { Faker::Company.name }
  let(:championship_name) { Faker::Company.name }

  before { signin_user coach }

  # rubocop:disable RSpec/ExampleLength
  describe 'with non existing items' do
    it 'coach sign in and add new match' do
      click_on 'add-match'

      assert_text 'Quelle équipe ?'
      select(team.name, from: 'Quelle équipe ?')
      click_on 'Next'

      assert_text 'Quelle compétition ?'
      click_on 'Ajouter une compétition'
      fill_in 'championship[name]', with: championship_name

      select calendar.name, from: 'Calendar'

      expect do
        click_on 'Créer un(e) Compétition'
        assert_text 'Compétition créée'
      end.to change(Championship, :count)

      assert_text 'Quel jour ?'
      click_on 'Ajouter une journée'
      select(17, from: 'day_period_start_date_3i')
      select('octobre', from: 'day_period_start_date_2i')
      select(2018, from: 'day_period_start_date_1i')
      fill_in 'day[name]', with: day_name
      expect do
        click_on 'Créer un(e) Journée'
        assert_text 'Journée créée'
      end.to change(Day, :count)

      assert_text 'Quel lieu ?'
      click_on 'Ajouter un lieu'
      fill_in 'location[name]', with: location_name
      fill_in 'location[address]', with: location_address
      expect do
        click_on 'Créer un(e) Lieu'
        assert_text 'Lieu créé'
      end.to change(Location, :count)

      assert_text 'Equipe adverse ?'
      click_on 'Ajouter une équipe'
      fill_in 'team[name]', with: adversary_team_name
      expect do
        click_on 'Créer un(e) Équipe'
        assert_text 'Équipe créée'
      end.to change(Team, :count)

      expect do
        click_on 'Créer un(e) Match'
        assert_text 'Match créé'
      end.to change(Match, :count)
      match = Match.last
      expect(match.local_team).to eq(team)
      expect(match.visitor_team.name).to eq(adversary_team_name)
      expect(match.day.name).to eq(day_name)
      expect(match.location.name).to eq(location_name)
    end
  end

  describe 'with existing items' do
    let(:championship) { create(:championship, name: championship_name) }
    let(:adversary_team) { create(:team, name: adversary_team_name) }
    let!(:day) { create(:day, calendar: championship.calendar, name: day_name) }
    let!(:location) { create(:location, name: location_name) }

    before do
      championship.enroll_team!(team)
      championship.enroll_team!(adversary_team)
    end

    it 'coach sign in and add new match' do
      click_on 'add-match'

      assert_text 'Quelle équipe ?'
      select(team.name, from: 'Quelle équipe ?')
      click_on 'Next'

      assert_text 'Quelle compétition ?'
      select championship.name, from: 'Quelle compétition ?'
      click_on 'Next'

      assert_text 'Quel jour ?'
      select day.name, from: 'Quel jour ?'
      click_on 'Next'

      assert_text 'Quel lieu ?'
      select location.name, from: 'Quel lieu ?'
      click_on 'Next'

      assert_text 'Equipe adverse ?'
      select adversary_team.name, from: 'Equipe adverse'
      click_on 'Next'

      assert_text 'Nouveau match'
      assert_text 'Local team'
      assert_text 'Par défault, une heure avant'
      expect do
        click_on 'Créer un(e) Match'
        assert_text 'Match créé'
      end.to change(Match, :count)

      match = Match.last
      expect(match.local_team).to eq(team)
      expect(match.visitor_team.name).to eq(adversary_team_name)
      expect(match.day.name).to eq(day_name)
      expect(match.location.name).to eq(location_name)
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
