# Feature: Invite user
#   As a section_coach
#   I want to invite a new user
#   So he can access the site
feature 'Add training', :devise do
  # Scenario: section_coach add new training
  #   Given I am a signed in section_coach
  #   When I go to trainings page
  #   Then I can create new training
  scenario 'section_coach sign in and add new player' do
    section_coach = create :user, :section_coach
    location = create :location
    signin section_coach.email, section_coach.password
    click_link 'Entrainements'
    click_link 'Ajouter un entrainement'

    select(location.name, :from => 'training_location_id')

    expect { click_button('Ajouter l\'entrainement') }.to change { Training.count }.by(1)
  end
end
