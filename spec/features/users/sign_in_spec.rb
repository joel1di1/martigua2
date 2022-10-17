# frozen_string_literal: true

# Feature: Sign in
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
describe 'Sign in', :devise do
  # Scenario: User cannot sign in if not registered
  #   Given I do not exist as a user
  #   When I sign in with valid credentials
  #   Then I see an invalid credentials message
  it 'user cannot sign in if not registered' do
    signin(Faker::Internet.email, 'please123')
    expect(page).to have_content 'Email ou mot de passe incorrect.'
  end

  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  it 'user can sign in with valid credentials' do
    user = create(:user)
    section = create :section
    section.add_player! user
    signin(user.email, user.password)
    expect(page).to have_content 'Connecté(e).'
    expect(page).to have_button user.email
    expect(page).to have_link 'Membres'
    expect(page).to have_link 'Entrainements'
  end

  # Scenario: User cannot sign in with wrong email
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  it 'user cannot sign in with wrong email' do
    user = create(:user)
    signin('invalid@email.com', user.password)
    expect(page).to have_content 'Email ou mot de passe incorrect.'
  end

  # Scenario: User cannot sign in with wrong password
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  it 'user cannot sign in with wrong password' do
    user = create(:user)
    signin(user.email, 'invalidpass')
    expect(page).to have_content 'Email ou mot de passe incorrect.'
  end
end
