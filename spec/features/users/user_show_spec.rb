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

  let(:section) { create(:section) }

  # Scenario: User sees own profile
  #   Given I am signed in
  #   When I visit the user profile page
  #   Then I see my own email address
  it 'user sees own profile' do
    user = create(:user, with_section: section)
    login_as(user, scope: :user)
    visit section_user_path(section, user)
    expect(page).to have_content user.email
  end

  # Scenario: if member of the same section, user can see another user's profile
  #   Given I am signed in in a section i'm member of
  #   When I visit another user's profile
  #   Then I see the other person profile
  it "user can see another user's profile if member of the same section" do
    section = create(:section)
    me = create(:user, with_section: section)
    other = create(:user, with_section: section)
    create(:participation, user: me, section:)
    create(:participation, user: other, section:)
    login_as(me, scope: :user)
    visit section_user_path(other, section_id: section.to_param)
    expect(page).to have_content other.email

    visit section_users_path(section_id: section.to_param)

    # full_name  capitalize all words
    click_on other.full_name.split.map(&:capitalize).join(' ')
    expect(page).to have_content other.phone_number
    expect(page).to have_current_path(section_user_path(other, section_id: section.to_param))
  end

  # Scenario: user can see his profile in the section url
  #   Given I am signed in in a section I'm member of
  #   When I visit my profile
  #   Then I see my profile
  it 'user can see his profile in the section url' do
    section = create(:section)
    me = create(:user, with_section: section)
    create(:participation, user: me, section:)
    login_as(me, scope: :user)
    visit section_user_path(me, section_id: section.to_param)
    expect(page).to have_content me.email
  end
end
