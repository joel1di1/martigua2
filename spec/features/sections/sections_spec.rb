# frozen_string_literal: true

describe 'sections admin task', :devise do
  let(:club) { create :club }
  let(:previous_section) { create :section, club: club }

  context 'club admin' do
    let(:admin) { create :user, with_club_as_admin: club, with_section: previous_section }

    before { signin admin.email, admin.password }

    it 'create a new section' do
      section_name = Faker::Company.name
      click_link admin.email
      click_link club.name
      save_and_open_page
      click_button 'Ajouter une section'
      fill_in('Name', with: section_name)

      expect do
        click_button 'Create Team'
        expect(page).to have_text("Section #{section_name} créée")
      end.to change(Team, :count).by(1)
    end

    it 'destroy old section' do
    end
  end
end
