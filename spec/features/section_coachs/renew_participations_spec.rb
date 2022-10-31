# frozen_string_literal: true

# Feature: Renew participations
#   As a section_coach
#   I want to select members from last season
#   To renew their participations
describe 'Renew Participations', :devise do
  # Scenario:
  #   Given I am a signed in section_coach
  #   When I visit members page with no members
  #   Then I see a link to renew previous participations
  #   And I can go to this page, select members and renew their participations
  it 'section_coach sign in and invite player' do
    section = create :section
    coach = create :user, with_section_as_coach: section

    # add a member in the previous season
    previous_season = Season.current.previous
    previous_player = create :user
    section.add_player!(previous_player, season: previous_season)

    renouveller = 'Renouveller de l\'année précédente'

    signin coach.email, coach.password
    expect(page).to have_link 'Membres'
    within '#links' do
      click_link 'Membres'
    end
    expect(page).to have_current_path section_users_path(section), ignore_query: true
    expect(page).not_to have_content previous_player.email
    expect(page).to have_link renouveller
    click_link renouveller

    expect(page).to have_current_path section_participations_renewal_index_path(section), ignore_query: true
    expect(page).to have_button 'submit_btn'

    click_button 'submit_btn'

    expect(page).to have_current_path section_users_path(section), ignore_query: true
    expect(page).to have_content previous_player.email
  end
end
