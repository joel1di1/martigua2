# frozen_string_literal: true

describe 'fill in training presences' do
  it 'section_coach sign in and invite player' do
    section = create(:section)
    player = create(:user, with_section: section)
    group = create(:group, section:)
    group.add_user! player
    training = create(:training, sections: [section], groups: [group], start_datetime: 1.day.from_now)

    expect(player.present_for?(training)).to be_nil

    signin player.email, player.password

    click_on 'Présent'
    assert_text "m'indiquer absent"
    expect(player.reload).to be_present_for(training)

    click_on "m'indiquer absent"
    assert_text "m'indiquer présent"
    expect(player.reload).not_to be_present_for(training)

    click_on "m'indiquer présent"
    assert_text "m'indiquer absent"
    expect(player.reload).to be_present_for(training)

    click_on "m'indiquer absent"
    assert_text "m'indiquer présent"
    expect(player.reload).not_to be_present_for(training)
  end
end
