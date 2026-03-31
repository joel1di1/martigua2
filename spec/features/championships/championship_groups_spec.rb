# frozen_string_literal: true

describe 'championship groups management', :devise do
  let(:section) { create(:section) }
  let(:coach) { create(:user, with_section_as_coach: section) }
  let(:championship1) { create(:championship, season: Season.current) }
  let(:championship2) { create(:championship, season: Season.current) }

  before do
    create(:team, with_section: section, enrolled_in: championship1)
    create(:team, with_section: section, enrolled_in: championship2)
    signin coach.email, coach.password, close_notice: true
  end

  def visit_groups_path
    visit section_championship_groups_path(section)
  end

  def visit_championships_path
    visit section_championships_path(section)
  end

  it 'shows a link to groups from the championships index' do
    visit_championships_path
    expect(page).to have_link('Groupes', href: section_championship_groups_path(section))
  end

  describe 'index' do
    context 'with no groups' do
      it 'shows empty state' do
        visit_groups_path
        expect(page).to have_text('Aucun groupe de compétitions pour cette section')
      end
    end

    context 'with an existing group' do
      let!(:group) { create(:championship_group, name: 'Groupe test') }

      before { group.add_championship(championship1, index: 0) }

      it 'lists groups with their championships' do
        visit_groups_path
        expect(page).to have_text('Groupe test')
        expect(page).to have_text(championship1.name)
      end
    end
  end

  describe 'create a group' do
    it 'creates a new group' do
      visit_groups_path
      click_on 'Nouveau groupe'
      fill_in 'Nom du groupe', with: 'Div 2 saison 2025'

      expect do
        click_on 'Créer'
        expect(page).to have_text('Groupe créé')
      end.to change(ChampionshipGroup, :count).by(1)

      expect(page).to have_text('Div 2 saison 2025')
    end
  end

  describe 'edit a group' do
    let!(:group) { create(:championship_group, name: 'Ancien nom') }

    before { group.add_championship(championship1, index: 0) }

    it 'renames the group' do
      visit_groups_path
      click_on 'Modifier'
      fill_in 'Nom du groupe', with: 'Nouveau nom'
      click_on 'Modifier'
      expect(page).to have_text('Groupe modifié')
      expect(page).to have_text('Nouveau nom')
    end
  end

  describe 'delete a group' do
    let!(:group) { create(:championship_group, name: 'À supprimer') }

    before { group.add_championship(championship1, index: 0) }

    it 'deletes the group', :js do
      visit_groups_path
      expect do
        accept_confirm { click_on 'Supprimer' }
        expect(page).to have_text('Groupe supprimé')
      end.to change(ChampionshipGroup, :count).by(-1)
    end
  end

  describe 'group show page' do
    let!(:group) { create(:championship_group, name: 'Groupe complet') }

    it 'adds a championship to the group', :js do
      visit section_championship_group_path(section, group)

      select championship1.name, from: 'championship_id'
      fill_in 'index', with: '1'
      click_on 'Ajouter'

      expect(page).to have_text('Compétition ajoutée au groupe')
      expect(page).to have_text(championship1.name)
    end

    context 'with a championship already in the group' do
      before { group.add_championship(championship1, index: 0) }

      it 'shows the championship with its index' do
        visit section_championship_group_path(section, group)
        expect(page).to have_text(championship1.name)
        expect(page).to have_text('0')
      end

      it 'removes a championship from the group' do
        visit section_championship_group_path(section, group)
        expect do
          click_on 'Retirer'
          expect(page).to have_text('Compétition retirée du groupe')
        end.to change(ChampionshipGroupChampionship, :count).by(-1)
      end
    end
  end

  describe 'group management from championship show' do
    let!(:group) { create(:championship_group, name: 'Groupe A') }

    it 'assigns a championship to a group' do
      visit section_championship_path(section, championship1)

      select 'Groupe A', from: 'championship_group_id'
      fill_in 'index', with: '1'
      click_on 'Enregistrer'

      expect(page).to have_text('Groupe mis à jour')
      expect(championship1.reload.championship_groups).to include(group)
    end

    context 'with the championship already in a group' do
      before { group.add_championship(championship1, index: 0) }

      it 'unassigns the championship from its group' do
        visit section_championship_path(section, championship1)

        select '— Aucun —', from: 'championship_group_id'
        click_on 'Enregistrer'

        expect(page).to have_text('Groupe mis à jour')
        expect(championship1.reload.championship_groups).to be_empty
      end
    end
  end
end
