# frozen_string_literal: true

describe 'create championship' do
  describe 'manually' do
    it 'creates a new championship' do
      section = create(:section)
      coach = create(:user, with_section_as_coach: section)
      championship = create(:championship)
      team = create(:team, with_section: section, enrolled_in: championship)

      alexis = create(:user, with_section: section, last_name: 'thirouin', first_name: 'alexi')
      clement = create(:user, with_section: section, last_name: 'Tamisier', first_name: 'Clément')

      signin coach.email, coach.password

      visit edit_section_path(section)

      within('#content') { assert_text section.name }
    end
  end
end
