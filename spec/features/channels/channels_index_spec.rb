# frozen_string_literal: true

# Feature: duty tasks
describe 'channels index' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let!(:random_chan) { create(:channel, section:) }

  before do
    signin_user user, close_notice: true
  end

  context 'with small screen' do
    it 'shows channels list' do
      within('#links') { click_on 'Chats' }

      expect(page).to have_current_path section_channels_path(section)

      # expects to see general channel and random channel
      expect(page).to have_css '#channels-list'
      expect(page).to have_css '#channels-list a', count: 2

      # expects to see general channel
      expect(page).to have_css '#channels-list a', text: 'Général'

      # expects to see random channel
      expect(page).to have_css '#channels-list a', text: random_chan.name
    end
  end
end
