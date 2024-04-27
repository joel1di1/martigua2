# frozen_string_literal: true

describe 'sections admin task', :devise do
  let(:club) { create(:club) }
  let(:previous_section) { create(:section, club:) }

  context 'with club admin' do
    let(:admin) { create(:user, with_club_as_admin: club, with_section: previous_section) }

    before { signin admin.email, admin.password, close_notice: true }

    it 'create a new section' do
      section_name = Faker::Company.name
      click_on admin.email
      click_on club.name

      assert_text '1 sections'
      click_on 'Ajouter une section'
      fill_in('Name', with: section_name)

      expect do
        click_button 'Créer un(e) Section'
        expect(page).to have_text("Section #{section_name} créée")
      end.to change(Section, :count).by(1)
    end

    it 'destroy old section' do
      click_on admin.email
      click_on club.name
      expect do
        click_button "delete-section-#{previous_section.id}"
        assert_text "Section #{previous_section.name} supprimée"
      end.to change(Section, :count).by(-1)
    end
  end
end
