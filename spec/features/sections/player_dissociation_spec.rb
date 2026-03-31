# frozen_string_literal: true

describe 'player FFHB dissociation', :devise do
  let(:section) { create(:section) }
  let(:player) { create(:user, with_section: section) }
  let!(:stat) do
    create(:user_championship_stat, user: player, championship:,
                                    player_id: 'ffhb_123', first_name: 'John', last_name: 'Doe', match_played: 5)
  end
  let(:coach) { create(:user, with_section_as_coach: section) }
  let(:championship) { create(:championship, season: Season.current) }

  before do
    create(:team, with_section: section, enrolled_in: championship)
    signin coach.email, coach.password, close_notice: true
  end

  def visit_edit_page
    visit edit_club_section_path(section.club, section)
  end

  it 'displays associated player name' do
    visit_edit_page
    within("turbo-frame#player_#{player.id}") do
      expect(page).to have_text(player.full_name)
      expect(page).to have_text('John Doe')
      expect(page).to have_link('Dissocier')
    end
  end

  it 'dissociates a player without reloading the page', :js do
    visit_edit_page

    within("turbo-frame#player_#{player.id}") do
      click_link 'Dissocier'
      expect(page).to have_select("section[player_#{player.id}]")
      expect(page).to have_no_button('Dissocier')
    end

    expect(stat.reload.user_id).to be_nil
  end

  it 'dissociates all players' do
    visit_edit_page
    click_button 'Dissocier tous les joueurs'
    expect(page).to have_text('Tous les joueurs ont été dissociés')
    expect(stat.reload.user_id).to be_nil
  end
end
