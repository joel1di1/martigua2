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
      # submit the form
      # expect to see the injury on the player profile
    end
  end
end
