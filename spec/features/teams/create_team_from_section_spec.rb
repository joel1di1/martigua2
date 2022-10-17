# frozen_string_literal: true

describe 'from section page', :devise do
  skip 'create a new team' do
    team_name = Faker::Company.name
    section = create :section
    club = section.club
    coach = create :user, with_section_as_coach: section

    signin coach.email, coach.password

    expect(page).to have_text('Équipes')

    click_on 'add-team'
    expect(page).to have_text('New team')

    fill_in('Name', with: team_name)
    select club.name, from: 'Club'

    expect { click_on 'Create Team' }.to change(Team, :count).by(1)

    team = Team.find_by(name: team_name)
    expect(team.sections.count).to eq(1)
    expect(team.sections.first).to eq(section)
    expect(team.club).to eq(club)
  end
end
