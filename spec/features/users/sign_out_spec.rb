# frozen_string_literal: true

# Feature: Sign out
#   As a user
#   I want to sign out
#   So I can protect my account from unauthorized access
describe 'Sign out', :devise do
  # Scenario: User signs out successfully
  #   Given I am signed in
  #   When I sign out
  #   Then I see a signed out message
  it 'user signs out successfully' do
    section = create :section
    user = create :user, with_section: section
    signin(user.email, user.password)
    expect(page).to have_content 'Connecté(e).'
    click_on 'Déconnexion'
    expect(page).to have_content 'Déconnecté(e).'
  end
end
