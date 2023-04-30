# frozen_string_literal: true

# Feature: duty tasks
describe 'channels' do
  it 'member sees general channel' do
    section = create(:section)
    user = create(:user, with_section: section)

    signin_user user, close_notice: true

    within '#links' do
      click_on 'Channels'
    end

    assert_text 'Général'
  end
end
