# frozen_string_literal: true

describe 'Absent player seen as unavailable for match', type: :feature do
  let(:section) { create(:section) }
  let(:coach) { create(:coach, with_section: section) }
  let(:player) { create(:user, with_section: section) }
  let(:match) { create(:match, local_team: section.teams.first) }

  before do
    signin_user coach
    match
    visit section_path(section)
  end

  it 'coach sees player as unavailable' do
    click_on "#{match.local_team&.name} - #{match.visitor_team&.name}"

    # check url match "sections/xxx/day/xxx/selections
    expect(page).to have_current_path(section_day_selections_path(section, match.day))
    assert_text '1 non dispos'
    click_on '1 non dispos'
    within '#non_available_players' do
      except(page).to have_text player.full_name
    end
  end
end
