# frozen_string_literal: true

describe 'display_events', :devise do
  # Scenario: member sees next 7 days events
  #   Given I am a signed users
  #   When I go to events
  #   Then I can see every events of the next 7 days
  it 'member sees next 7 days events' do
    section = create(:section)
    team = create(:team, with_section: section)
    user = create(:user, with_section: section)
    next_training = create(:training, start_datetime: 2.days.from_now, with_section: section)
    next_match = create(:match, start_datetime: 3.days.from_now, local_team: team)

    signin_user user, close_notice: true

    visit section_events_path(section)

    # Wait for page to load first
    expect(page).to have_link 'Prochains événements'

    # Wait for turbo frame to complete lazy loading
    # The turbo stream removes the placeholder div when loading completes
    # Long wait time needed for parallel test execution under heavy load
    expect(page).to have_no_css('#events_placeholder', wait: 30)

    assert_text I18n.l(next_training.start_datetime, format: '%a %d %b %R')
    assert_text next_match.local_team.name
    assert_text 'vs'
    assert_text next_match.visitor_team.name
  end
end
