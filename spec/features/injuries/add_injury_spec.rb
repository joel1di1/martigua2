# frozen_string_literal: true

describe 'Add Injury', :devise do
  let(:section) { create(:section) }
  let(:coach) { create(:coach, with_section: section) }
  let(:player) { create(:user, with_section: section) }

  describe 'as player' do
    before { signin_user player }

    it 'player can add injury' do
      # connect on the player profile
      visit section_user_path(section, player)

      expect(page).to have_text '0 blessures'

      # click on the add injury button
      click_on 'Ajouter une blessure'

      # fill in the form
      fill_in 'Nom de la blessure', with: 'Entorse cheville gauche'
      fill_in 'Commentaire', with: 'Blessure de merde lors du dernier match'
      fill_in 'injury[start_at]', with: '23/06/2024'
      fill_in 'injury[end_at]', with: '12/08/2024'
      # submit the form
      click_on 'Ajouter la blessure'
      # expect to see the injury on the player profile
      expect(page).to have_text '1 blessures'
      expect(page).to have_text 'Entorse cheville gauche'
    end
  end
end
