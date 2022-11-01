# frozen_string_literal: true

describe 'Active Admin', :devise do
  it 'admin can list any page in admin section' do
    admin = create(:user)
    create(:admin_user, email: admin.email)

    signin admin.email, admin.password
    visit '/admin'

    expect(page).to have_content 'Users'

    create(:admin_user)
    create(:championship)
    create(:calendar)
    create(:day)
    create(:club)
    create(:location)
    create(:season)
    create(:section)
    create(:team_section)
    create(:team)
    create(:training)
    create(:training_presence)
    create(:user)

    admins_pages = ['Admin Users', 'Calendar', 'Compétitions', 'Clubs', 'Journées', 'Lieux', 'Seasons', 'Sections',
                    'Trainings', 'Training Presences', 'Utilisateurs']

    admins_pages.each do |admin_page|
      click_link admin_page
      expect(page.all('#page-title', text: admin_page).size).to eq 1

      click_link "Création #{admin_page.chop.downcase}"
      expect(page.all('h1.main-content__page-title', text: "Création #{admin_page.chop}").size).to eq(1), admin_page
    end
  end
end
