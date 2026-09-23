# frozen_string_literal: true

# Feature: Manage teams
#   As a coach of a section
#   I want to add, modify and delete teams of the section
#   So the section's competing teams are up to date
describe 'Manage teams', :devise, :js do
  it 'section_coach adds, modifies and deletes a team' do
    section_coach = create(:user, :section_coach)
    signin section_coach.email, section_coach.password

    within '#links' do
      click_on 'Équipes'
    end
    expect(page).to have_text('0 équipes')

    click_on 'Ajouter une équipe'
    expect(page).to have_text('Ajouter une équipe')

    fill_in 'team[name]', with: 'Les -18 masculins'
    expect do
      click_on "Ajouter l'équipe"
      assert_text 'Équipe créée'
    end.to change(Team, :count).by(1)

    expect(page).to have_text('Les -18 masculins')

    click_on 'Les -18 masculins'
    click_on 'Modifier'

    fill_in 'team[name]', with: 'Les -18 féminins'
    click_on 'Enregistrer'
    assert_text 'Équipe modifiée'
    expect(page).to have_text('Les -18 féminins')

    expect do
      accept_confirm { click_on "Supprimer l'équipe" }
      assert_text 'Équipe supprimée'
    end.to change(Team, :count).by(-1)
  end
end
