# frozen_string_literal: true

# Feature: User profile page
#   As a user
#   I want to visit my user profile page
#   So I can see my personal account data
describe 'User profile page', :devise do
  include Warden::Test::Helpers
  Warden.test_mode!

  after do
    Warden.test_reset!
  end

  # Scenario: User sees own profile
  #   Given I am signed in
  #   When I visit the user profile page
  #   Then I see my own email address
  it 'user sees own profile' do
    user = FactoryBot.create(:user)
    login_as(user, :scope => :user)
    visit user_path(user)
    expect(page).to have_content user.email
  end

  # Scenario: User cannot see another user's profile
  #   Given I am signed in
  #   When I visit another user's profile
  #   Then I see an 'access denied' message
  it "user cannot see another user's profile" do
    me = FactoryBot.create(:user)
    other_email = Faker::Internet.email
    other = FactoryBot.create(:user, email: other_email)
    login_as(me, :scope => :user)
    Capybara.current_session.driver.header 'Referer', root_path
    visit user_path(other)
    expect(page).to have_content 'Access denied.'
  end
end
