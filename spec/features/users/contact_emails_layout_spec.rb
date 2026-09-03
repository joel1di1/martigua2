# frozen_string_literal: true

describe 'Relatives emails on the member edit page', :devise, :js do
  let(:section) { create(:section) }
  let(:player) { create(:user, with_section: section) }

  it 'lists existing relatives above the add row' do
    create(:user_contact_email, user: player, email: 'maman@example.com', label: 'Maman')
    signin player.email, player.password
    expect(page).to have_text 'Connecté(e).'

    visit edit_section_user_path(section, player)

    expect(page).to have_text 'Lien'
    expect(page).to have_text 'maman@example.com'

    fill_in 'user_contact_email_label', with: 'Papa'
    fill_in 'user_contact_email_email', with: 'papa@example.com'
    click_on 'Ajouter'

    expect(page).to have_text 'Email de contact ajouté'
    expect(player.reload.contact_emails.pluck(:label, :email))
      .to contain_exactly(['Maman', 'maman@example.com'], ['Papa', 'papa@example.com'])
  end
end
