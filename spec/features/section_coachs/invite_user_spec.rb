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
  scenario 'section_coach sign in and invite player' do
    section_coach = create :user, :section_coach
    signin section_coach.email, section_coach.password
    expect(page).to have_link 'Membres'
    click_link 'Membres'
    expect(current_path).to eq section_users_path(section_coach.sections.first)
    expect(page).to have_link 'Ajouter un joueur'
    click_link 'Ajouter un joueur'
    expect(current_path).to eq new_section_section_user_invitation_path(section_coach.sections.first)

    invited_user = build :user
    fill_in 'section_user_invitation[email]', with: invited_user.email
    fill_in 'section_user_invitation[first_name]', with: invited_user.first_name
    fill_in 'section_user_invitation[last_name]', with: invited_user.last_name
    fill_in 'section_user_invitation[nickname]', with: invited_user.nickname
    fill_in 'section_user_invitation[phone_number]', with: invited_user.phone_number

    expect{click_button('Inviter le joueur')}.to change{SectionUserInvitation.count}.by(1)
  end

end
