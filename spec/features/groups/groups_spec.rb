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
        click_on 'Groupes'
      end
      expect(page).to have_text section.group_everybody.name
    end

    it 'visit the group page with 2 groups' do
      group1 = create(:group, section:)
      group2 = create(:group, section:)

      group1.add_user!(user)
      within '#links' do
        click_on 'Groupes'
      end

      expect(page).to have_text group1.name
      expect(page).to have_text group2.name
      expect(page).to have_text section.group_everybody.name

      click_on group1.name
      expect(page).to have_text group1.name
    end
  end

  describe 'coach' do
    let(:user) { create(:user, with_section_as_coach: section) }

    it 'admin creates new group' do
      within '#links' do
        click_on 'Groupes'
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

  describe 'design preference' do
    let(:user) { create(:user, with_section: section) }

    it 'offers the new design on the groups pages and lets the user switch back', :js do
      visit section_groups_path(section)
      expect(page).to have_css '#new-design-banner'

      click_on 'Essayer le nouveau design'

      expect(page).to have_no_css '#new-design-banner'
      expect(user.reload).to be_new_design
      expect(page).to have_text 'pour la saison'

      expect(page).to have_css('el-dropdown:defined')
      click_on 'Ouvrir le menu utilisateur'
      click_on "Revenir à l'ancien design"

      expect(page).to have_css '#new-design-banner'
      expect(user.reload).not_to be_new_design
    end

    it 'does not show the banner on pages without a new design', driver: :rack_test do
      visit section_users_path(section)
      expect(page).to have_css '#navbar'
      expect(page).to have_no_css '#new-design-banner'
    end
  end

  describe 'coach with the new design', driver: :rack_test do
    let(:user) { create(:user, with_section_as_coach: section, new_design: true) }

    it 'admin creates new group' do
      within '#links' do
        click_on 'Groupes'
      end
      assert_text '2 groupes'

      click_on 'Ajouter un groupe'

      fill_in 'group[name]', with: Faker::Game.title
      fill_in 'group[name]', with: Faker::Games::LeagueOfLegends.quote

      expect do
        click_on 'Créer le groupe'
        assert_text 'Groupe créé'
      end.to change(Group, :count).by(1)
    end

    it 'coach edits a group' do
      group = create(:group, section:, name: 'Gardiens')
      visit section_group_path(section, group)

      click_on 'Modifier'
      fill_in 'Nom', with: 'Gardiennes'
      click_on 'Enregistrer'

      assert_text 'Groupe modifié'
      expect(group.reload.name).to eq 'Gardiennes'
    end

    it 'coach sees validation errors when editing a group' do
      group = create(:group, section:)
      visit edit_section_group_path(section, group)

      fill_in 'Nom', with: ''
      click_on 'Enregistrer'

      expect(page).to have_text "Le groupe n'a pas pu être enregistré"
    end

    it 'coach adds then removes a member', driver: :selenium_chrome do
      group = create(:group, section:)
      player = create(:user, with_section: section)
      visit section_group_path(section, group)

      find_by_id('user_id-ts-control').fill_in with: player.first_name
      find('.ts-dropdown .option', text: player.full_name).click
      click_on 'Ajouter'
      expect(page).to have_text player.email
      expect(group.reload.users).to include(player)

      expect(page).to have_css('el-dropdown:defined')
      click_on "Options pour #{player.full_name}"
      accept_confirm { click_on 'Retirer du groupe' }
      expect(page).to have_no_text player.email
      expect(group.reload.users).not_to include(player)
    end

    it 'coach deletes a group from its edit page' do
      group = create(:group, section:)
      visit edit_section_group_path(section, group)

      expect do
        click_on 'Supprimer ce groupe'
        assert_text 'supprimé'
      end.to change(Group, :count).by(-1)
    end
  end
end
