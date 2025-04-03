# frozen_string_literal: true

# Feature: duty tasks
RSpec.describe 'channels', :js do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:other_user) { create(:user, with_section: section) }

  def assert_message_in_viewport(message)
    message_div = find("div#message_#{message.id}")

    in_view = evaluate_script("(function(el) {
      var rect = el.getBoundingClientRect();
      return (
        rect.top >= 0 && rect.left >= 0 &&
        rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
        rect.right <= (window.innerWidth || document.documentElement.clientWidth)
      )
    })(arguments[0]);", message_div)

    assert in_view, "Expected message #{message.id} to be in viewport, but it wasn't"
  end

  it 'last read message and first read message should be displayed' do
    skip 'This test is flaky and needs to be fixed'
    general = section.general_channel

    messages = (0...100).map do
      create(:message, channel: general, user: other_user)
    end

    user.read!(messages[0..50].map(&:id))

    signin_user user, close_notice: true

    within '#links' do
      click_on 'Chats'
    end

    click_on 'Général'

    assert_message_in_viewport(messages[50])
    assert_message_in_viewport(messages[51])
  end
end
