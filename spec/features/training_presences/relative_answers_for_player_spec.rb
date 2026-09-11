# frozen_string_literal: true

describe 'a relative answers for a player' do
  let(:section) { create(:section) }
  let(:player) { create(:user, with_section: section) }
  let(:group) { create(:group, section:) }
  let(:training) { create(:training, sections: [section], groups: [group], start_datetime: 1.day.from_now) }

  before do
    group.add_user! player
    training
    create(:user_contact_email, user: player, email: 'maman@example.com', label: 'Maman')
  end

  it 'gets a login link, signs in as the player and declares the presence' do
    # `Sidekiq.testing!(:inline) { ... }` only sets the mode for the current
    # Thread. The real Chrome/Puma server used by feature specs handles the
    # request on a different Thread, so the block form would leave jobs
    # merely enqueued (fake mode) instead of running them inline.
    Sidekiq.testing!(:inline)

    visit new_login_link_path
    fill_in 'email', with: 'maman@example.com'
    click_on 'Envoyer le lien'

    assert_text 'un lien de connexion vient de vous être envoyé'

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq ['maman@example.com']

    visit mail.body.decoded[/href="(http[^"]*user_token=[^"]*)"/, 1].gsub('&amp;', '&')

    click_on 'Présent'
    assert_text "m'indiquer absent"

    expect(player.reload).to be_present_for(training)
  ensure
    Sidekiq.testing!(:fake)
  end

  it 'is welcomed on being added, and answers from that mail' do
    other_player = create(:user, with_section: section)
    group.add_user! other_player
    signin other_player.email, other_player.password, close_notice: true

    # See comment above: the block form of `Sidekiq.testing!` is Thread-local
    # and wouldn't affect the Puma Thread handling this feature spec's request.
    Sidekiq.testing!(:inline)

    visit edit_section_user_path(section, other_player)
    fill_in 'user_contact_email_email', with: 'papa@example.com'
    click_on 'Ajouter'
    assert_text 'Email de contact ajouté'

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq ['papa@example.com']
    expect(mail.subject).to include(other_player.full_name)

    visit mail.body.decoded[/href="(http[^"]*user_token=[^"]*)"/, 1].gsub('&amp;', '&')

    click_on 'Présent'
    assert_text "m'indiquer absent"

    expect(other_player.reload).to be_present_for(training)
  ensure
    Sidekiq.testing!(:fake)
  end

  it 'is copied on the training invitation sent to the player' do
    Sidekiq.testing!(:inline) do
      UserMailer.send_training_invitation(training, player).deliver_now
    end

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq [player.email]
    expect(mail.cc).to eq ['maman@example.com']
  end
end
