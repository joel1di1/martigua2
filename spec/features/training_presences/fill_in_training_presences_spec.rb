# frozen_string_literal: true

describe 'fill in training presences', :devise do
  it 'section_coach sign in and invite player' do
    section = create :section
    player = create :user, with_section: section
    group = create :group, section: section
    group.add_user! player
    training = create :training, sections: [section], groups: [group]

    expect(player.present_for?(training)).to be_nil

    signin player.email, player.password

    click_on 'Présent ?'
    expect(player.reload).to be_is_present_for(training)

    click_on 'Non présent'
    expect(player.reload.present_for?(training)).to eq false

    click_on 'Présent'
    expect(player.reload).to be_is_present_for(training)

    click_on 'Non présent'
    expect(player.reload.present_for?(training)).to eq false
  end
end
