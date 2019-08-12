# frozen_string_literal: true

# Feature: duty tasks
feature 'duty_tasks', :devise do
  # Scenario: member sees duty tasks
  #   Given I am a signed users
  #   When I go to duty tasks
  #   Then I can see every tasks
  scenario 'member sees duty tasks' do
    section = create :section
    user = create :user, with_section: section
    signin user.email, user.password

    click_on 'Tigs'
  end

  # Scenario: member creates a duty task
  #   Given I am a signed user
  #   When I go to duty tasks
  #   Then I can create a duty task
  scenario 'member creates duty tasks' do
    section = create :section
    user = create :user, with_section: section
    signin user.email, user.password

    click_on 'Tigs'
    click_on 'Nouvelle tache'
  end
end
