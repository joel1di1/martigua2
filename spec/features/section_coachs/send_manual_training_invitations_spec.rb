# frozen_string_literal: true

# Feature: Invite user
#   As a coach
#   I want to invite a new user
#   So he can access the site
describe 'send training invitation', :devise, :js do
  # Scenario: coach add new training
  #   Given I am a signed in coach
  #   When I go to trainings page
  #   Then I can create new training
  it 'coach send training invitation' do
    skip 'This test is flaky and needs to be fixed'
    section = create(:section)
    coach = create(:user, with_section_as_coach: section)
    training = create(:training, :futur, with_section: section)

    signin coach.email, coach.password
    within '#links' do
      click_on 'Entrainements'
    end

    submit_id = "training_invitations_#{training.id}"
    expect do
      accept_confirm('Renvoyer les mails pour les indécits ?') { click_on(submit_id) }
      assert_selector(:xpath, "//*[contains(text(), 'Notifications envoyées')]", visible: :all)
    end.to change { training.invitations.count }.by(1)
  end
end
