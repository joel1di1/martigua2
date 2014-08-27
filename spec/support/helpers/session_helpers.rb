module Features
  module SessionHelpers
    def sign_up_with(email, password, confirmation)
      visit new_user_registration_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', :with => confirmation
      click_button 'Sign up'
    end

    def signin(email, password)
      visit root_path
      fill_in 'Email', with: email
      fill_in 'Mot de passe', with: password
      click_button 'Se connecter'
    end

    def signin_user(user)
      signin(user.email, user.password)
    end
  end
end
