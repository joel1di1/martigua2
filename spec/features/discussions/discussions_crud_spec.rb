# frozen_string_literal: true

# Feature: duty tasks
describe 'discussions' do
  skip 'member sees general discussion' do
    section = create(:section)
    user = create(:user, with_section: section)

    signin_user user, close_notice: true

    within '#links' do
      click_on 'Discussions'
    end

    assert_text 'Général'
  end
end
