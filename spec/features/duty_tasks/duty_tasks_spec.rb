# frozen_string_literal: true

# Feature: duty tasks
describe 'duty_tasks', :devise do
  # Scenario: member sees duty tasks
  #   Given I am a signed users
  #   When I go to duty tasks
  #   Then I can see every tasks
  it 'member sees duty tasks' do
    section = create :section
    user = create :user, with_section: section
    signin user.email, user.password

    click_on 'Tigs'
  end

  # Scenario: member creates a duty task
  #   Given I am a signed user
  #   When I go to duty tasks
  #   Then I can create a duty task
  it 'member creates duty tasks' do
    section = create :section
    user = create :user, with_section: section
    signin user.email, user.password

    click_on 'Tigs'
    click_on 'créer une nouvelle tache'
  end
end
