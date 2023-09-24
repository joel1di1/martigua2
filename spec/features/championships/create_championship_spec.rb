# frozen_string_literal: true

RSpec.feature 'create championship', type: :feature, js: true do
  describe 'manually' do
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

      expect do
        click_on 'Créer un(e) Compétition'
        assert_text 'Compétition créée'
      end.to change(Championship, :count).by(1)

      championship = Championship.find_by(name: championship_name)
      expect(championship.teams.count).to eq(1)
      expect(championship.teams.first).to eq(team)
    end
  end

  describe 'with ffhb' do
    before { mock_ffhb }

    skip 'creates a new championship with a section team' do
      section = create(:section)
      coach = create(:user, with_section_as_coach: section)
      team = create(:team, with_section: section)

      signin coach.email, coach.password

      within '#links' do
        click_on 'Compétitions'
      end

      click_on 'Ajouter une compétition depuis la FFHB'

      select('Départements', from: 'type_competition')
      click_on 'Valider'

      select('94 - COMITE DU VAL-DE-MARNE', from: 'code_comite')
      click_on 'Valider'

      select('+16 ANS MACULINE 2 EME DIVISION TERRITORIALE', from: 'code_competition')
      click_on 'Valider'

      select('+16 ANS MACULINE 2 EME DIVISION TERRITORIALE', from: 'phase_id')
      click_on 'Valider'

      select('UNIQUE', from: 'code_pool')
      click_on 'Valider'

      select(team.name, from: 'team_links[1589702]')

      expect { click_on 'Créer la compétition et lier les équipes' }.to change(Championship, :count)

      championship = Championship.find_by(ffhb_key: '2023-2024-19 departemental 16-ans-maculine-2-eme-division-territoriale-23229 41894 128335')
      expect(championship.teams.size).to eq 12
    end
  end
end
