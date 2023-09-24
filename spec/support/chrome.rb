# frozen_string_literal: true

RSpec.configure do |_config|
  # NOTE: Capybara registers this by default
  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver :selenium_chrome_headless do |app|
    options = Selenium::WebDriver::Chrome::Options.new

    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1280,800')

    Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
  end

  Capybara.current_driver = :selenium_chrome if ENV['SHOW_BROWSER'].present?
end
