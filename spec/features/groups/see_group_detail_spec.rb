# frozen_string_literal: true

describe 'See group detail' do
  let(:section) { create :section }
  let(:user) { create :user, with_section: section }

  before { signin_user user }

  it 'visit the group page with defaults groups' do
    click_link 'Groupes'
    expect(page).to have_content section.group_everybody.name
  end

  it 'visit the group page with 2 groups' do
    group1 = create :group, section: section
    group2 = create :group, section: section

    group1.add_user!(user)
    click_link 'Groupes'

    expect(page).to have_content group1.name
    expect(page).to have_content group2.name
    expect(page).to have_content section.group_everybody.name

    click_link group1.name
    expect(page).to have_content group1.name
  end
end
