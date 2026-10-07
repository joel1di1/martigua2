# frozen_string_literal: true

# Feature: Validate training presences
#   As a coach of a section
#   I want to tick the players who really came to a training
#   So players who said they would come but did not are counted as absent
describe 'Validate training presences', :devise, :js do
  let(:section) { create(:section) }
  let(:group) { create(:group, section:) }
  let(:training) do
    create(:training, sections: [section], groups: [group], start_datetime: 1.day.ago, max_capacity: nil)
  end
  let(:cheater) { create(:user, first_name: 'Alice', last_name: 'Tricheuse', with_section: section, with_group: group) }
  let(:silent) { create(:user, first_name: 'Bruno', last_name: 'Silencieux', with_section: section, with_group: group) }

  before do
    cheater.present_for!(training)
    silent
  end

  it 'section_coach overrides the declared answers of the players' do
    coach = create(:user, with_section_as_coach: section)
    signin_user coach

    within('#links') { click_on 'Entrainements' }
    click_on '1 présents / 0 absents / 1 sans réponse'
    click_on 'Valider les présences'

    expect(page).to have_text("Entrainement du #{I18n.l(training.start_datetime, format: :short)}")

    within("#presence-player-#{cheater.id}") do
      expect(page).to have_text('A dit présent').and have_no_text('Validé par le coach')
      uncheck cheater.full_name
      expect(page).to have_text('Validé par le coach').and have_css('.bg-green-200')
    end

    within("#presence-player-#{silent.id}") do
      expect(page).to have_text('Pas de réponse').and have_no_text('Validé par le coach')
      check silent.full_name
      expect(page).to have_text('Validé par le coach').and have_css('.bg-yellow-200')
    end

    within('#links') { click_on 'Membres' }
    within('tr', text: 'Alice Tricheuse') do
      expect(page).to have_css('svg.text-red-600', count: 1).and have_no_css('svg.text-green-600')
    end
    within('tr', text: 'Bruno Silencieux') do
      expect(page).to have_css('svg.text-green-600', count: 1).and have_no_css('svg.text-red-600')
    end
  end

  it 'player does not see the presence validation link' do
    signin_user cheater
    expect(page).to have_css('#links')

    visit section_training_path(section, training)

    expect(page).to have_text('Entrainement du')
    expect(page).to have_no_link('Valider les présences')
  end
end
