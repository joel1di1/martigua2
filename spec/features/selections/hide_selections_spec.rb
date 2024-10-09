# frozen_string_literal: true

describe 'Hide selections', :devise do
  let(:section) { create(:section) }
  let(:coach) { create(:user, with_section_as_coach: section) }
  let(:player) { create(:user, with_section: section) }
  let(:team) { create(:team, with_section: section) }
  let(:match) { create(:match, local_team: team) }
  let(:day) { match.day }

  describe 'Coach hide selection for players' do
    it 'changes day visibility' do
      signin_user coach

      visit section_day_selections_path(section, day)

      click_on 'Masquer les sélections'
      expect(page).to have_text 'Les sélections sont masquées, cliquer ici pour les afficher'
      expect(day.reload).to be_selection_hidden

      click_on 'Les sélections sont masquées, cliquer ici pour les afficher'
      expect(page).to have_text 'Masquer les sélections'
      expect(day.reload).not_to be_selection_hidden
    end
  end

  describe 'Player' do
    before { day.update!(selection_hidden: true) }

    it 'cannot see hidden selection' do
      signin_user player

      visit section_day_selections_path(section, day)

      expect(page).to have_text 'Les sélections sont en cours de construction'
    end

    it 'cannot see selection on match page' do
      signin_user player

      visit section_match_path(section, match)

      expect(page).to have_text 'Les sélections sont en cours de construction'
    end
  end
end
