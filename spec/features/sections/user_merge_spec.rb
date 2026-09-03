# frozen_string_literal: true

describe 'Merge a parent account into a player contact email', :devise, :js do
  let(:section) { create(:section) }
  let(:coach) { create(:user, with_section_as_coach: section) }
  let!(:parent) { create(:user, email: 'maman@example.com', last_name: 'Dupond', with_section: section) }
  let!(:child) { create(:user, first_name: 'Lea', last_name: 'Dupond', with_section: section) }

  it 'moves the parent address onto the player and deletes the parent account' do
    signin coach.email, coach.password
    expect(page).to have_text 'Connecté(e).'

    visit new_section_user_merge_path(section)
    select_in_tom_select 'user_merge_source_id', parent.email
    select_in_tom_select 'user_merge_target_id', child.email
    fill_in 'Libellé (optionnel)', with: 'Maman'

    accept_confirm { click_on 'Fusionner et supprimer le compte' }

    expect(page).to have_text 'maman@example.com'
    expect(child.reload.contact_email_addresses).to eq ['maman@example.com']
    expect(child.contact_emails.first.label).to eq 'Maman'
    expect(User.exists?(parent.id)).to be false
  end

  # TomSelect replaces the native select once its controller connects, which can lag
  # behind the page load when the whole suite runs.
  def select_in_tom_select(select_id, text)
    find("##{select_id}-ts-control", wait: 15).click
    find('.ts-dropdown .option', text:).click
  end
end
