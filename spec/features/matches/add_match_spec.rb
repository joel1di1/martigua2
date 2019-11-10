# frozen_string_literal: true

describe 'Add Match', :devise do
  it 'coach sign in and add new match' do
    adversary_team_name = Faker::Team.name
    location_name = Faker::Address.street_name
    location_address = Faker::Address.full_address
    day_name = Faker::Company.name

    coach = create :coach
    team = coach.sections.first.teams.sample

    calendar = create :calendar

    signin_user coach

    click_on 'add-match'

    assert_text 'Quelle équipe ?'
    select(team.name, from: 'Quelle équipe ?')
    click_on 'Next'

    assert_text 'Quelle compétition ?'
    click_on 'Ajouter une compétition'
    fill_in 'championship[name]', with: Faker::Company.name

    select calendar.name, from: 'Calendar'

    expect { click_on 'Create Championship' }.to change(Championship, :count)

    assert_text 'Quel jour ?'
    click_on 'Ajouter une journée'
    fill_in 'day[period_start_date]', with: '17/11/2018'
    fill_in 'day[name]', with: day_name
    expect { click_on 'Create Day' }.to change(Day, :count)

    assert_text 'Quel lieu ?'
    click_on 'Ajouter un lieu'
    fill_in 'location[name]', with: location_name
    fill_in 'location[address]', with: location_address
    expect { click_on 'Create Location' }.to change(Location, :count)

    assert_text 'Equipe adverse ?'
    click_on 'Ajouter une équipe'
    fill_in 'team[name]', with: adversary_team_name
    expect { click_on 'Create Team' }.to change(Team, :count)

    expect { click_on 'Create Match' }.to change(Match, :count)
    match = Match.last
    expect(match.local_team).to eq(team)
    expect(match.visitor_team.name).to eq(adversary_team_name)
    expect(match.day.name).to eq(day_name)
    expect(match.location.name).to eq(location_name)
  end
end
