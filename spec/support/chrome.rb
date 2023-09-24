# frozen_string_literal: true

RSpec.configure do |_config|
  Capybara.register_driver :selenium_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless') unless ENV['SHOW_BROWSER'].present?
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1280,800')

    Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
  end

  Capybara.current_driver = :selenium_chrome
end
