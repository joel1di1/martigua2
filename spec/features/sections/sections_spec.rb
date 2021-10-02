# frozen_string_literal: true

describe 'sections admin task', :devise do
  let(:club) { create :club }
  let(:previous_section) { create :section, club: club }

  context 'with club admin' do
    let(:admin) { create :user, with_club_as_admin: club, with_section: previous_section }

    before { signin admin.email, admin.password }

    it 'create a new section' do
      section_name = Faker::Company.name
      click_link admin.email
      click_link club.name
      click_link 'Ajouter une section'
      fill_in('Name', with: section_name)

      expect do
        click_button 'Create Section'
        expect(page).to have_text("Section #{section_name} créée")
      end.to change(Section, :count).by(1)
    end

    it 'destroy old section' do
      click_link admin.email
      click_link club.name
      expect do
        click_link "delete-section-#{previous_section.id}"
        assert_text "Section #{previous_section.name} supprimée"
      end.to change(Section, :count).by(-1)
    end
  end
end
