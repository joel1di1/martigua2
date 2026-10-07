# frozen_string_literal: true

describe 'trainings pagination' do
  it 'shows the pagination labels in French' do
    section = create(:section)
    player = create(:user, with_section: section)
    11.times { |i| create(:training, with_section: section, start_datetime: (i + 1).days.from_now) }

    signin player.email, player.password
    visit section_trainings_path(section, page: 1)

    expect(page).to have_link('Suivante ›')
    expect(page).to have_link('Dernière »')

    click_on 'Suivante ›'

    expect(page).to have_link('« Première')
    expect(page).to have_link('‹ Précédente')
    expect(page).to have_no_css('.translation_missing')
  end
end
