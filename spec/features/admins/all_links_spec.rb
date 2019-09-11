# frozen_string_literal: true

feature 'Active Admin', :devise do
  scenario 'admin can list any page in admin section' do
    admin = create :admin_user

    visit '/admin'

    fill_in 'admin_user_email', with: admin.email
    fill_in 'admin_user_password', with: admin.password

    click_button 'Login'

    expect(page).to have_content 'Dashboard'

    create :admin_user
    create :championship
    create :calendar
    create :day
    create :club
    create :location
    create :season
    create :section
    create :team_section
    create :team
    create :training
    create :training_presence
    create :user

    admins_pages = ['Admin Users', 'Calendar', 'Championships', 'Clubs', 'Days', 'Locations', 'Seasons', 'Sections', 'Team Sections', 'Trainings', 'Training Presences', 'Users']

    admins_pages.each do |admin_page|
      puts admin_page
      click_link admin_page
      expect(page.all('#page_title', :text => admin_page).size).to eq 1

      new_title = "New #{admin_page.chop}"
      click_link new_title
      expect(page.all('#page_title', :text => new_title).size).to eq 1
    end
  end
end
