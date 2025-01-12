# frozen_string_literal: true

module Features
  module SessionHelpers
    def sign_up_with(email, password, confirmation)
      visit new_user_registration_path
      fill_in 'Email', with: email
      fill_in 'Mot de passe', with: password
      fill_in 'Confirmation du mot de passe', with: confirmation
      click_on 'Inscription'
    end

    def signin(email, password, close_notice: false)
      visit root_path
      fill_in 'user[email]', with: email
      fill_in 'Mot de passe', with: password
      click_on 'Se connecter'

      click_on 'close-flash-notice' if close_notice
    end

    def signin_user(user, close_notice: false)
      signin(user.email, user.password, close_notice:)
    end
  end
end

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end
