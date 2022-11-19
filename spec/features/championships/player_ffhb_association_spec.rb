# frozen_string_literal: true

describe 'create championship' do
  describe 'manually' do
    it 'creates a new championship' do
      section = create(:section)
      coach = create(:user, with_section_as_coach: section)
      championship = create(:championship, ffhb_key: '110562', season: Season.current)
      team = create(:team, with_section: section, enrolled_in: championship)
      championship.ffhb_sync!

      alexis = create(:user, with_section: section, last_name: 'thirouin', first_name: 'alexi')
      clement = create(:user, with_section: section, last_name: 'Tamisier', first_name: 'Clément')

      signin_user coach, close_notice: true

      click_on coach.email
      click_on section.club.name

      within('#content') { assert_text section.club.name }
      within('#content') { assert_text section.name }

      find("#edit-section-#{section.id}").click

      assert_text 'Nom du joueur'
      assert_text 'Joueur FFHB'

      within("#player-#{alexis.id}") do 
        assert_text alexis.full_name
        expect(page).to have_select("section[player_#{alexis.id}]", selected: 'ALEXIS THIROUIN') 
      end

      within("#player-#{clement.id}") do 
        assert_text clement.full_name
        expect(page).to have_select("section[player_#{clement.id}]", selected: 'CLEMENT TAMISIER') 
      end
    end
  end
end
