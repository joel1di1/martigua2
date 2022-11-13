# frozen_string_literal: true

module Features
  module SessionHelpers
    def sign_up_with(email, password, confirmation)
      visit new_user_registration_path
      fill_in 'Email', with: email
      fill_in 'Mot de passe', with: password
      fill_in 'Confirmation du mot de passe', with: confirmation
      click_button 'Sign up'
    end

    def signin(email, password, close_notice: false)
      visit root_path
      fill_in 'Email', with: email
      fill_in 'Mot de passe', with: password
      click_button 'Se connecter'

      click_button 'close-flash-notice' if close_notice
    end

    def signin_user(user)
      signin(user.email, user.password)
    end
  end
end

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end
