# frozen_string_literal: true

RSpec.configure do |_config|
  Capybara.register_driver :selenium_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new

    options.add_argument('--headless') if ENV['SHOW_BROWSER'].blank?
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-search-engine-choice-screen')
    options.add_argument('--window-size=1280,800')

    Capybara::Selenium::Driver.new(app, browser: :chrome, options:).tap do |driver|
      # chromedriver raises UnknownError "Node with given id does not belong to the document" when
      # a page swap lands mid-lookup. Capybara only retries stale-element errors, so retry this one too.
      # shortcut: retries every UnknownError until the wait time runs out, narrow it if that hides real bugs.
      driver.invalid_element_errors << Selenium::WebDriver::Error::UnknownError
    end
  end

  Capybara.javascript_driver = :selenium_chrome
end
