feature 'See group detail' do

  let(:section) { create :section }
  let(:user) { create :user, with_section: section }

  before { signin_user user }

  scenario 'visit the group page with no group' do
    click_link 'Groupes'
    expect(page).to have_content 'Aucun groupe défini'
  end

  scenario 'visit the group page with 2 groups' do
    group_1 = create :group, section: section
    group_2 = create :group, section: section

    click_link 'Groupes'

    expect(page).to have_content group_1.name
    expect(page).to have_content group_2.name
  end

  scenario 'visit a group page with 2 groups' do
    group = create :group, section: section

    click_link 'Groupes'
    click_link group.name

    expect(page).to have_content group.name
  end


end
