# frozen_string_literal: true

# Feature: Renew participations
#   As a section_coach
#   I want to select members from last season
#   To renew their participations
feature 'Renew Participations', :devise do
  # Scenario:
  #   Given I am a signed in section_coach
  #   When I visit members page with no members
  #   Then I see a link to renew previous participations
  #   And I can go to this page, select members and renew their participations
  scenario 'section_coach sign in and invite player' do
    section = create :section
    coach = create :user, with_section_as_coach: section

    # add a member in the previous season
    previous_season = Season.current.previous
    previous_player = create :user
    section.add_player!(previous_player, season: previous_season)

    renouveller = 'Renouveller de l\'année précédente'

    signin coach.email, coach.password
    expect(page).to have_link 'Membres'
    click_link 'Membres'
    expect(current_path).to eq section_users_path(section)
    expect(page).not_to have_content previous_player.email
    expect(page).to have_link renouveller
    click_link renouveller

    expect(current_path).to eq section_participations_renewal_index_path(section)
    expect(page).to have_button 'submit_btn'

    click_button 'submit_btn'

    expect(current_path).to eq section_users_path(section)
    expect(page).to have_content previous_player.email
  end
end
