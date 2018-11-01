feature 'Add Match', :devise do
  scenario 'coach sign in and add new match' do
    adversary_team_name = Faker::Team.name
    location_name = Faker::Address.street_name
    location_address = Faker::Address.full_address
    day_name = Faker::Company.name

    coach = create :coach
    team = coach.sections.first.teams.sample

    signin_user coach

    click_on 'add-match'

    assert_text 'Quelle équipe ?'
    select(team.name, from: "Quelle équipe ?")
    click_on 'next'

    assert_text 'Quelle compétition ?'
    click_on 'Ajouter une compétition'
    fill_in 'championship[name]', with: Faker::Company.name
    expect { click_on 'Create Championship' }.to change { Championship.count }

    assert_text 'Quel jour ?'
    click_on 'Ajouter une journée'
    fill_in 'day[period_start_date]', with: '17/11/2018'
    fill_in 'day[name]', with: day_name
    expect { click_on 'Create Day' }.to change { Day.count }

    assert_text 'Quel lieu ?'
    click_on 'Ajouter un lieu'
    fill_in 'location[name]', with: location_name
    fill_in 'location[address]', with: location_address
    expect { click_on 'Create Location' }.to change { Location.count }

    assert_text 'Equipe adverse ?'
    click_on 'Ajouter une équipe'
    fill_in 'team[name]', with: adversary_team_name
    expect { click_on 'Create Team' }.to change { Team.count }

    select team.name, from: 'Local team'
    select adversary_team_name, from: 'Visitor team'
    select location_name, from: 'Location'
    select day_name, from: 'Day'

    expect { click_on 'Create Match' }.to change { Match.count }
  end
end
