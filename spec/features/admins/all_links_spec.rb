# frozen_string_literal: true

describe 'Active Admin', :devise do
  let(:admins_pages) do
    [
      'Admin Users',
      'Calendars',
      'Compétitions',
      'Clubs',
      'Club Admin Roles',
      'Journées',
      'Duty Tasks',
      'Enrolled Team Championships',
      'Groups',
      'Lieux',
      'Matchs',
      'Match Availabilit',
      'Match Selections',
      'Participations',
      'Seasons',
      'Sections',
      'Section User Invitations',
      'Selections',
      'Équipes',
      'Trainings',
      'Training Invitations',
      'Training Presences',
      'Utilisateurs'
    ]
  end

  before do
    create(:admin_user)
    create(:calendar)
    create(:championship)
    create(:club)
    create(:day)
    create(:location)
    create(:season)
    create(:section)
    create(:team)
    create(:team_section)
    create(:training)
    create(:training_presence)
    create(:user)
    create(:match)
  end

  it 'admin can list any page in admin section' do
    admin = create(:user)
    create(:admin_user, email: admin.email)

    signin admin.email, admin.password
    visit '/admin'

    expect(page).to have_content 'Users'

    admins_pages.each do |admin_page|
      click_on admin_page
      expect(page.all('#page-title', text: admin_page).size).to eq 1

      click_on "Création #{admin_page.chop.downcase}"
      expect(page.all('h1.main-content__page-title', text: "Création #{admin_page.chop}").size).to eq(1), admin_page
    end
  end
end
