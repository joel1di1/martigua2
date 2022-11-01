# frozen_string_literal: true

# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
describe 'Sign Up', :devise do
  # Scenario: Visitor can sign up with valid email address and password
  #   Given I am not signed in
  #   When I sign up with a valid email address and password
  #   Then I see a successful sign up message
  it 'visitor can sign up with valid email address and password' do
    sign_up_with(Faker::Internet.email, 'please123', 'please123')
    expect(page).to have_content 'Bienvenue ! Vous vous êtes bien enregistré(e).'
  end

  # Scenario: Visitor cannot sign up with invalid email address
  #   Given I am not signed in
  #   When I sign up with an invalid email address
  #   Then I see an invalid email message
  it 'visitor cannot sign up with invalid email address' do
    sign_up_with('bogus', 'please123', 'please123')
    expect(page).to have_content "Email n'est pas valide"
  end

  # Scenario: Visitor cannot sign up without password
  #   Given I am not signed in
  #   When I sign up without a password
  #   Then I see a missing password message
  it 'visitor cannot sign up without password' do
    sign_up_with(Faker::Internet.email, '', '')
    expect(page).to have_content 'Mot de passe doit être rempli(e)'
  end

  # Scenario: Visitor cannot sign up with a short password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  it 'visitor cannot sign up with a short password' do
    sign_up_with(Faker::Internet.email, 'ple', 'ple')
    expect(page).to have_content 'Mot de passe est trop court (au moins 4 caractères)'
  end

  # Scenario: Visitor cannot sign up without password confirmation
  #   Given I am not signed in
  #   When I sign up without a password confirmation
  #   Then I see a missing password confirmation message
  it 'visitor cannot sign up without password confirmation' do
    sign_up_with(Faker::Internet.email, 'please123', '')
    expect(page).to have_content 'Confirmation du mot de passe ne concorde pas avec Mot de passe'
  end

  # Scenario: Visitor cannot sign up with mismatched password and confirmation
  #   Given I am not signed in
  #   When I sign up with a mismatched password confirmation
  #   Then I should see a mismatched password message
  it 'visitor cannot sign up with mismatched password and confirmation' do
    sign_up_with(Faker::Internet.email, 'please123', 'mismatch')
    expect(page).to have_content 'Confirmation du mot de passe ne concorde pas avec Mot de passe'
  end
end
