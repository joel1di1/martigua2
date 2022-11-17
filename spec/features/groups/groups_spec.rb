# frozen_string_literal: true

describe 'See group detail' do
  let(:section) { create(:section) }

  before do
    signin_user user, close_notice: true
    section.group_everybody
    section.group_every_players
  end

  describe 'player' do
    let(:user) { create(:user, with_section: section) }

    it 'visit the group page with defaults groups' do
      within '#links' do
        click_link 'Groupes'
      end
      expect(page).to have_content section.group_everybody.name
    end

    it 'visit the group page with 2 groups' do
      group1 = create(:group, section:)
      group2 = create(:group, section:)

      group1.add_user!(user)
      within '#links' do
        click_link 'Groupes'
      end

      expect(page).to have_content group1.name
      expect(page).to have_content group2.name
      expect(page).to have_content section.group_everybody.name

      click_link group1.name
      expect(page).to have_content group1.name
    end
  end

  describe 'coach' do
    let(:user) { create(:user, with_section_as_coach: section) }

    it 'admin creates new group' do
      within '#links' do
        click_link 'Groupes'
      end
      assert_text '2 groupes'

      click_on 'Ajouter un groupe'

      fill_in 'group[name]', with: Faker::Game.title
      fill_in 'group[name]', with: Faker::Games::LeagueOfLegends.quote

      expect do
        click_on 'Créer un(e) Group'
        assert_text 'Groupe créé'
      end.to change(Group, :count).by(1)
    end
  end
end
