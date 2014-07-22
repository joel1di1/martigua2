# Feature: Invite user
#   As a section_coach
#   I want to invite a new user
#   So he can access the site
feature 'Invite User', :devise do

  # Scenario: section_coach add new training
  #   Given I am a signed in section_coach 
  #   When I go to trainings page
  #   Then I can create new training
  scenario 'section_coach sign in and add nez  player' do
    section_coach = create :user, :section_coach
    signin section_coach.email, section_coach.password
    click_link 'Entrainements'
    click_link 'Ajouter un entrainement'

    new_training = build :training
    # fill_in 'section_user_invitation[email]', with: invited_user.email
    # fill_in 'section_user_invitation[first_name]', with: invited_user.first_name
    # fill_in 'section_user_invitation[last_name]', with: invited_user.last_name
    # fill_in 'section_user_invitation[nickname]', with: invited_user.nickname
    # fill_in 'section_user_invitation[phone_number]', with: invited_user.phone_number

    # expect{click_button('Inviter le joueur')}.to change{SectionUserInvitation.count}.by(1)
  end

end
