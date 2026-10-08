# frozen_string_literal: true

describe 'Filtering the player stats', :devise, :js do
  let(:club) { create(:club) }
  let(:section) { create(:section, club:) }
  let(:championship) { create(:championship, season: Season.current) }
  let(:our_team) { create(:team, club:, with_section: section, enrolled_in: championship) }
  let(:match) do
    create(:match, championship:, local_team: our_team, visitor_team: create(:team, enrolled_in: championship),
                   day: create(:day, calendar: championship.calendar))
  end
  let(:member) { create(:user, with_section: section) }

  def create_player_with_stats(last_name:, position:)
    player = create(:user, with_section: section, last_name:)
    player.participations.find_by(section:, role: Participation::PLAYER).update!(main_position: position)
    create(:player_match_stat, match:, team: our_team, user: player, first_name: player.first_name, last_name:)
  end

  before do
    create_player_with_stats(last_name: 'GARDIEN', position: 'goalkeeper')
    create_player_with_stats(last_name: 'PIVOT', position: 'pivot')
    signin member.email, member.password
    visit section_player_stats_path(section)
  end

  it 'filters by position, keeps the selection, then resets the filters' do
    expect(page).to have_no_link 'Réinitialiser'

    select 'Gardien', from: 'Poste'
    click_on 'Filtrer'

    expect(page).to have_no_text 'PIVOT'
    expect(page).to have_text 'GARDIEN'
    expect(page).to have_select 'Poste', selected: 'Gardien'

    click_on 'Réinitialiser'

    expect(page).to have_text 'PIVOT'
    expect(page).to have_text 'GARDIEN'
    expect(page).to have_select 'Poste', selected: 'Tous'
    expect(page).to have_no_link 'Réinitialiser'
  end
end
