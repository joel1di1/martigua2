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
    user = create(:user)
    login_as(user, scope: :user)
    visit user_path(user)
    expect(page).to have_content user.email
  end

  # Scenario: User cannot see another user's profile
  #   Given I am signed in
  #   When I visit another user's profile
  #   Then I see an 'access denied' message
  it "user cannot see another user's profile" do
    me = create(:user)
    other_email = Faker::Internet.email
    other = create(:user, email: other_email)
    login_as(me, scope: :user)
    Capybara.current_session.driver.header 'Referer', root_path
    visit user_path(other)
    expect(page).to have_content 'Access denied (403)'
  end

  # Scenario: if member of the same section, user can see another user's profile
  #   Given I am signed in in a section i'm member of
  #   When I visit another user's profile
  #   Then I see the other person profile
  it "user can see another user's profile if member of the same section" do
    section = create(:section)
    me = create(:user)
    other = create(:user)
    create(:participation, user: me, section:)
    create(:participation, user: other, section:)
    login_as(me, scope: :user)
    visit section_user_path(other, section_id: section.to_param)
    expect(page).to have_content other.email

    visit section_users_path(section_id: section.to_param)
    click_link other.full_name
    expect(page).to have_content other.phone_number
    expect(page).to have_content 'Surnom'
  end

  # Scenario: user can see his profile in the section url
  #   Given I am signed in in a section I'm member of
  #   When I visit my profile
  #   Then I see my profile
  it 'user can see his profile in the section url' do
    section = create(:section)
    me = create(:user)
    create(:participation, user: me, section:)
    login_as(me, scope: :user)
    visit section_user_path(me, section_id: section.to_param)
    expect(page).to have_content me.email
  end
end
