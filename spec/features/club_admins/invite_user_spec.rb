# Feature: Invite user
#   As a section_coach
#   I want to invite a new user
#   So he can access the site
feature 'Invite User', :devise do

  # Scenario: section_coach sign in and see invitation form
  #   Given I am a signed in section_coach 
  #   When I visit club root page
  #   Then I see members page
  #   And I can invite new users
  scenario 'section_coach sign in and see invitation form' do
    section_coach = create :user, :section_coach
    signin section_coach.email, section_coach.password
    expect(page).to have_link 'Joueurs'
    click_link 'Joueurs'
    expect(current_path).to eq section_users_path(section_coach.sections.first)
    expect(page).to have_link 'Ajouter un joueur'
  end

end
