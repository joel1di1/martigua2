# frozen_string_literal: true

# Feature: Admin impersonation
#   As a super admin
#   I want to log in as another user from the user menu
#   So I can reproduce what they see, and come back to my own account
describe 'Admin impersonation', :devise, :js do
  let(:section) { create(:section) }
  # the switch_user guards are hard-coded on this email (config/initializers/switch_user.rb)
  let!(:admin) do
    create(:user, email: 'joel1di1@gmail.com', first_name: 'alice', last_name: 'admin', nickname: nil,
                  with_section: section)
  end
  # the email is fixed and sorts before the admin's one: ordering by email and ordering by name
  # give opposite results, so the "name-sorted" example really exercises available_users.
  let!(:player) do
    create(:user, first_name: 'jean', last_name: 'dupont', nickname: nil, email: 'aaa@example.com',
                  with_section: section)
  end

  def open_user_menu(user)
    click_on user.email
  end

  # TomSelect is loaded from a CDN, hence the generous wait on the first boot.
  def open_options
    using_wait_time(15) { find('#switch-user-widget .ts-control').click }
  end

  def switch_to(user)
    open_options
    find('#switch-user-widget .ts-dropdown .option', text: user.email).click
  end

  it 'lets the super admin impersonate another user' do
    signin_user(admin, close_notice: true)
    open_user_menu(admin)

    expect(page).to have_css '#switch-user-widget label[for]', text: 'Se connecter en tant que'

    switch_to(player)

    expect(page).to have_css '#current-user-email', text: player.email
    expect(page).to have_css '#impersonation-badge', text: 'Impersonation'
  end

  it 'shows readable, name-sorted options' do
    signin_user(admin, close_notice: true)
    open_user_menu(admin)
    open_options

    labels = all('#switch-user-widget .ts-dropdown .option').map(&:text)

    expect(labels).to eq ["Alice Admin (#{admin.email})", "Jean Dupont (#{player.email})"]
    # the dropdown shows these two options and nothing else: no "User" group header
    expect(page).to have_css '#switch-user-widget .ts-dropdown',
                             exact_text: "Alice Admin (#{admin.email}) Jean Dupont (#{player.email})",
                             normalize_ws: true
  end

  it 'switches back to the admin account without signing out' do
    signin_user(admin, close_notice: true)
    open_user_menu(admin)
    switch_to(player)
    expect(page).to have_css '#impersonation-badge', text: 'Impersonation'

    open_user_menu(player)
    # a GET that changes the session must not be fired by Turbo on hover
    expect(page).to have_css '#switch-user-back[data-turbo-prefetch="false"]'
    click_on "Revenir à mon compte (#{admin.email})"

    # the badge is nested in that span: an exact match proves the admin is back, without it
    expect(page).to have_css '#current-user-email', exact_text: admin.email, normalize_ws: true

    open_user_menu(admin)
    expect(page).to have_text 'Se connecter en tant que'
  end

  it 'keeps the original account when chaining impersonations' do
    other = create(:user, first_name: 'zoe', last_name: 'zeta', nickname: nil, with_section: section)
    signin_user(admin, close_notice: true)
    open_user_menu(admin)
    switch_to(player)

    open_user_menu(player)
    switch_to(other)

    expect(page).to have_css '#current-user-email', text: other.email

    open_user_menu(other)
    click_on "Revenir à mon compte (#{admin.email})"

    expect(page).to have_css '#current-user-email', exact_text: admin.email, normalize_ws: true
  end

  it 'does not show the widget to a regular user' do
    user = create(:user, with_section: section)
    signin_user(user, close_notice: true)
    open_user_menu(user)

    # the menu is really open: without this, the negative below would pass trivially
    expect(page).to have_button 'Déconnexion'
    expect(page).to have_no_css '#switch-user-widget'
  end
end
