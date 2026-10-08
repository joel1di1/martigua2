# frozen_string_literal: true

describe 'Add Match', :devise, :js do
  let(:coach) { create(:coach) }
  let(:team) { coach.sections.first.teams.sample }
  # Faker can generate names with consecutive spaces (e.g. "Rang Leo  Hamon"),
  # which the browser collapses in rendered text, so text matchers would miss
  # them: squish the generated names.
  let(:adversary_team_name) { Faker::Team.name.squish }
  let(:location_name) { Faker::Address.street_name.squish }
  let(:location_address) { Faker::Address.full_address }
  let(:day_name) { Faker::Company.name.squish }
  let(:championship_name) { Faker::Company.name.squish }
  let(:calendar_name) { Faker::Company.name.squish }

  before { signin_user coach }

  # The creation of a championship/day/location/team is handled via a Turbo
  # Stream that updates the wizard's select in place, without leaving the
  # step (the select for the adversary-team step is a Tom Select widget, so
  # its underlying native <select> isn't visible - check the confirmation
  # text instead, which works regardless of the field's own visibility). If
  # Turbo hasn't taken over the form yet, the browser falls back to a
  # full-page redirect that lands directly on the next step instead.
  #
  # Waiting for the submit button to disappear is not enough: Turbo disables
  # the submitter while the request is in flight, so a plain `have_no_button`
  # passes before the server has created the record. Each stream action is
  # also applied on its own animation frame, so the confirmation can show up
  # before the panel collapses; clicking 'Suivant' in between can miss the
  # button when the page height shrinks under the cursor.
  def create_inline(model, button:, confirmation_text:, next_step:)
    expect do
      click_on button
      expect(page).to have_text(confirmation_text).or have_text(next_step)
    end.to change(model, :count)
    return unless page.has_text?(confirmation_text, wait: 0)

    expect(page).to have_no_button(button, disabled: :all)
    click_on 'Suivant'
  end

  # rubocop:disable RSpec/ExampleLength
  describe 'with non existing items' do
    it 'coach sign in and add new match' do
      click_on 'add-match'

      assert_text 'Quelle équipe ?'
      select(team.name, from: 'Quelle équipe ?')
      click_on 'Suivant'

      assert_text 'Quelle compétition ?'
      click_on 'Ajouter une compétition'
      fill_in 'championship[name]', with: championship_name

      click_on 'Ajouter un calendrier'
      fill_in 'calendar[name]', with: calendar_name
      click_on 'Créer un(e) Calendrier'
      expect(page).to have_select('Calendrier', selected: calendar_name, wait: 5)

      create_inline(Championship, button: 'Créer un(e) Compétition',
                                  confirmation_text: "✓ Compétition « #{championship_name} » créée et sélectionnée.",
                                  next_step: 'Quel jour ?')

      assert_text 'Quel jour ?'
      click_on 'Ajouter une journée'
      select(17, from: 'day_period_start_date_3i')
      select('octobre', from: 'day_period_start_date_2i')
      select(2024, from: 'day_period_start_date_1i')
      fill_in 'day[name]', with: day_name
      create_inline(Day, button: 'Créer un(e) Journée',
                         confirmation_text: "✓ Journée « #{day_name} » ajoutée et sélectionnée.",
                         next_step: 'Quel lieu ?')

      assert_text 'Quel lieu ?'
      click_on 'Ajouter un lieu'
      fill_in 'location[name]', with: location_name
      fill_in 'location[address]', with: location_address
      create_inline(Location, button: 'Créer un(e) Lieu',
                              confirmation_text: "✓ Lieu « #{location_name} » ajouté et sélectionné.",
                              next_step: 'Equipe adverse ?')

      assert_text 'Equipe adverse ?'
      click_on 'Ajouter une équipe'
      fill_in 'team[name]', with: adversary_team_name
      create_inline(Team, button: 'Créer un(e) Équipe',
                          confirmation_text: "✓ Équipe « #{adversary_team_name} » ajoutée et sélectionnée.",
                          next_step: 'Par défault, une heure avant')

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
      click_on 'Suivant'

      assert_text 'Quelle compétition ?'
      select championship.name, from: 'Quelle compétition ?'
      click_on 'Suivant'

      assert_text 'Quel jour ?'
      select day.name, from: 'Quel jour ?'
      click_on 'Suivant'

      assert_text 'Quel lieu ?'
      select location.name, from: 'Quel lieu ?'
      click_on 'Suivant'

      assert_text 'Equipe adverse ?'
      select adversary_team.name, from: 'adversary_team_id'
      click_on 'Suivant'

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
