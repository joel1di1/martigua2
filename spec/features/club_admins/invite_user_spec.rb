# Feature: Invite user
#   As a club administrator
#   I want to invite a new user
#   So he can access the site
feature 'Invite User', :devise do

  # Scenario: Admin sign in and see invitation form
  #   Given I am a signed in club admin 
  #   When I visit club root page
  #   Then I see members page
  #   And I can invite new users
  scenario 'Admin sign in and see invitation form' do
    club_admin = create :user, :club_admin
    signin club_admin.email, club_admin.password
    expect(page).to have_link 'Members'
  end

end
