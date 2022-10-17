# frozen_string_literal: true

# Feature: User edit
#   As a user
#   I want to edit my user profile
#   So I can change my email address
describe 'User edit', :devise do
  include Warden::Test::Helpers
  Warden.test_mode!

  after do
    Warden.test_reset!
  end

  # Scenario: User changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  it 'user changes email address' do
    section = create :section
    user = create :user, with_section: section
    new_email = Faker::Internet.email
    login_as(user, scope: :user)
    visit edit_user_registration_path(user)
    fill_in 'Email', with: new_email
    fill_in 'Mot de passe actuel', with: user.password
    click_button 'Update'
    expect(page).to have_content 'Votre compte a bien été modifié.'
  end

  # Scenario: Change member role
  #   Given I am signed in as admin
  #   When I change user roles
  #   Then I see an user updated roles
  it 'user changes roles' do
    section = create :section
    user = create :user, with_section: section
    coach = create :user, with_section_as_coach: section
    login_as(coach, scope: :user)
    visit edit_section_user_url(section, user)
    check 'Coach'
    uncheck 'Player'
    click_button 'Modifier ce(tte) Utilisateur'

    expect(page).to have_content 'Prochains matchs'
    user.reload
    expect(user).to be_coach_of(section, season: nil)
    expect(user).not_to be_player_of(section, season: nil)
    # expect(page).to have_content 'You updated your account successfully.'
  end

  # Scenario: User cannot edit another user's profile
  #   Given I am signed in
  #   When I try to edit another user's profile
  #   Then I see my own 'edit profile' page
  it "user cannot cannot edit another user's profile", :me do
    section = create :section
    me = create :user, with_section: section
    other_email = Faker::Internet.email
    other = create(:user, email: other_email)
    login_as(me, scope: :user)
    visit edit_user_registration_path(other)
    expect(page).to have_content 'Edit User'
    expect(page).to have_field('Email', with: me.email)
  end
end
