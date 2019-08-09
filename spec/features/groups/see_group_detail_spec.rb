# frozen_string_literal: true

feature 'See group detail' do
  let(:section) { create :section }
  let(:user) { create :user, with_section: section }

  before { signin_user user }

  scenario 'visit the group page with defaults groups' do
    click_link 'Groupes'
    expect(page).to have_content section.group_everybody.name
  end

  scenario 'visit the group page with 2 groups' do
    group_1 = create :group, section: section
    group_2 = create :group, section: section

    click_link 'Groupes'

    expect(page).to have_content group_1.name
    expect(page).to have_content group_2.name
    expect(page).to have_content section.group_everybody.name
  end
end
