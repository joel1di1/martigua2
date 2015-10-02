# Feature: send sms notification
#   As a section_coach
#   I want to send messages
#   So I provide information to them
feature 'send sms notification', :devise do

  # Scenario: section_coach sign in and see invitation form
  #   Given I am a signed in section_coach 
  #   When I visit send notification page
  #   Then I a form 
  #   And I can send sms to users
  scenario 'section_coach sign in and invite player' do
    section_coach = create :user, :section_coach
    signin section_coach.email, section_coach.password
    expect(page).to have_link 'Notification SMS'

    click_link 'Notification SMS'
    expect(current_path).to eq new_section_sms_notification_path(section_coach.sections.first)

    sms_notification = build :sms_notification
    fill_in 'sms_notification[title]', with: sms_notification.title
    fill_in 'sms_notification[description]', with: sms_notification.description

    expect{click_button('Envoyer')}.to change{SmsNotification.count}.by(1)
  end

  scenario 'section simple member sign in and do not see sms notifications' do
    section_member = create :one_section_player
    signin section_member.email, section_member.password
    expect(page).not_to have_link 'Notification SMS'
  end

end
