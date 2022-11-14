# frozen_string_literal: true

RSpec.configure do |config|
  # Note: Capybara registers this by default
  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver :selenium_chrome_headless do |app|
    options = Selenium::WebDriver::Chrome::Options.new

    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1280,800')

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.current_driver = ENV['SHOW_BROWSER'].present? ? :selenium_chrome : :selenium_chrome_headless

  # Capybara.javascript_driver = :webkit

end
