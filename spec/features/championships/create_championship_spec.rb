# frozen_string_literal: true

describe 'create championship', :devise do
  it 'creates a new championship' do
    championship_name = Faker::Company.name

    section = create(:section)
    coach = create(:user, with_section_as_coach: section)
    team = create(:team, with_section: section)
    calendar = create(:calendar)

    signin coach.email, coach.password

    within '#links' do
      click_on 'Compétitions'
    end
    click_on 'Ajouter une compétition manuellement'

    fill_in('Name', with: championship_name)
    select(calendar.name, from: 'Calendar')
    select(team.name, from: 'Teams')

    expect { click_on 'Créer un(e) Compétition' }.to change(Championship, :count).by(1)

    championship = Championship.find_by(name: championship_name)
    expect(championship.teams.count).to eq(1)
    expect(championship.teams.first).to eq(team)
  end
end
