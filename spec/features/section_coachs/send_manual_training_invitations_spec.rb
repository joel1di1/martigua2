# Feature: Invite user
#   As a coach
#   I want to invite a new user
#   So he can access the site
feature 'send training invitation', :devise do
  # Scenario: coach add new training
  #   Given I am a signed in coach 
  #   When I go to trainings page
  #   Then I can create new training
  scenario 'coach send training invitation' do
    section = create :section
    coach = create :user, with_section_as_coach: section
    training = create :training, with_section: section

    signin coach.email, coach.password
    click_link 'Entrainements'

    submit_id = "training_invitations_#{training.id}"
    expect{click_button(submit_id)}.to change{training.invitations.count}.by(1)
  end
end
