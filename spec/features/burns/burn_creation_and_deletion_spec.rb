# frozen_string_literal: true

describe 'burns', :devise do
  it 'coach creates then deletes burn' do
    section = create(:section)
    coach = create(:user, with_section_as_coach: section)
    player = create(:user, with_section: section)
    team = create(:team, with_section: section)
    championship = create(:championship, season: Season.current)
    championship.enroll_team!(team)

    signin_user coach

    click_on 'Compétitions'
    assert_text championship.name

    click_on championship.name
    assert_text '0 brûlés'

    select(player.full_name, from: 'burn[user]')

    expect do
      click_on 'Brûler !'
      assert_text "#{player.full_name} brûlé !"
    end.to change(player.reload.burns, :count)

    expect(player.reload.burns.first.championship).to eq(championship)

    # check that user is inside burned player
    within '#burned-players' do
      assert_text player.full_name
    end

    expect do
      click_on "unburn-#{player.id}"
      assert_text "#{player.full_name} rétabli"
    end.to change(player.reload.burns, :count).by(-1)
  end
end
