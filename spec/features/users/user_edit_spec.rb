# frozen_string_literal: true

# Feature: User edit
#   As a user
#   I want to edit my user profile
#   So I can change my email address
feature 'User edit', :devise do
  include Warden::Test::Helpers
  Warden.test_mode!

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  scenario 'user changes email address' do
    section = create :section
    user = create :user, with_section: section
    new_email = Faker::Internet.email
    login_as(user, :scope => :user)
    visit edit_user_registration_path(user)
    fill_in 'Email', :with => new_email
    fill_in 'Current password', :with => user.password
    click_button 'Update'
    expect(page).to have_content 'You updated your account successfully.'
  end

  # Scenario: User cannot edit another user's profile
  #   Given I am signed in
  #   When I try to edit another user's profile
  #   Then I see my own 'edit profile' page
  scenario "user cannot cannot edit another user's profile", :me do
    section = create :section
    me = create :user, with_section: section
    other_email = Faker::Internet.email
    other = FactoryBot.create(:user, email: other_email)
    login_as(me, :scope => :user)
    visit edit_user_registration_path(other)
    expect(page).to have_content 'Edit User'
    expect(page).to have_field('Email', with: me.email)
  end
end
