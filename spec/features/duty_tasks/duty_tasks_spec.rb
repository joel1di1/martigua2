# frozen_string_literal: true

# Feature: duty tasks
describe 'duty_tasks', :devise do
  # Scenario: member sees duty tasks
  #   Given I am a signed users
  #   When I go to duty tasks
  #   Then I can see every tasks
  it 'member sees duty tasks' do
    section = create(:section)
    user = create(:user, with_section: section)
    task1 = create(:duty_task, user:, realised_at: 2.days.ago, club: section.club)
    signin_user user, close_notice: true

    within '#links' do
      click_on 'Tigs'
    end


  end

  # Scenario: member creates a duty task
  #   Given I am a signed user
  #   When I go to duty tasks
  #   Then I can create a duty task
  it 'member creates duty tasks' do
    section = create(:section)
    user = create(:user, with_section: section)
    signin_user user, close_notice: true

    within '#links' do
      click_on 'Tigs'
    end
    assert_text 'Tâches collectives'

    click_on 'Ajouter une tâche'
    assert_text 'Nouvelle tache'

    expect do
      select user.full_name, from: 'duty_task[user_id]'
      select 'Faire la table', from: 'duty_task[key]'

      click_on 'Créer une nouvelle tâche'
      assert_text 'TIG créée'
    end.to change(DutyTask, :count)
  end
end
