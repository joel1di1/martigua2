# frozen_string_literal: true

RSpec.configure do |_config|
  Capybara.register_driver :selenium_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new

    options.add_argument('--headless') if ENV['SHOW_BROWSER'].blank?
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-search-engine-choice-screen')
    options.add_argument('--window-size=1280,800')

    Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
  end

  # Capybara::RSpec resets Capybara.current_driver back to Capybara.default_driver
  # after every example, so default_driver must be set here too - otherwise only
  # the very first feature example in the whole run gets real Chrome/Turbo and
  # every other one silently falls back to rack_test (no JS at all).
  Capybara.default_driver = :selenium_chrome
  Capybara.current_driver = :selenium_chrome
  Capybara.javascript_driver = :selenium_chrome
end
