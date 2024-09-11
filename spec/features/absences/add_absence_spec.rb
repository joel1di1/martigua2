# frozen_string_literal: true

describe 'Add Absence', :devise do
  let(:section) { create(:section) }
  let(:coach) { create(:coach, with_section: section) }
  let(:player) { create(:user, with_section: section) }

  describe 'as player' do
    before { signin_user player }

    it 'player can add absence' do
      # connect on the player profile
      visit section_user_path(section, player)

      expect(page).to have_text '0 absences'

      # click on the add absence button
      click_on 'Ajouter une absence'

      # fill in the form
      select 'Blessure', from: 'Motif'
      fill_in 'Commentaire', with: 'Entorse cheville gauche'
      fill_in 'absence[start_at]', with: '23/06/2024'
      fill_in 'absence[end_at]', with: '12/08/2024'
      # submit the form
      click_on 'Ajouter l\'absence'
      # expect to see the absence on the player profile
      expect(page).to have_text '1 absences'
      expect(page).to have_text 'Entorse cheville gauche'
      expect(page).to have_text 'Blessure'
    end
  end
end
