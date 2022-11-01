# frozen_string_literal: true

# Feature: User index page
#   As a user
#   I want to see a list of users
#   So I can see who has registered
describe 'User index page', :devise do
  include Warden::Test::Helpers
  Warden.test_mode!

  after do
    Warden.test_reset!
  end

  # Scenario: User listed on index page
  #   Given I am signed in
  #   When I visit the user index page
  #   Then I see my own email address
  it 'user sees own email address' do
    section = create(:section)
    user = create(:user, with_section: section)
    login_as(user, scope: :user)
    visit section_users_path(section_id: section.to_param)
    expect(page).to have_content user.email
  end
end
