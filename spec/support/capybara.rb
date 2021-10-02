# frozen_string_literal: true

Capybara.asset_host = 'http://localhost:3000'

# Capybara.register_driver :chrome do |app|
#   Capybara::Selenium::Driver.new(app, browser: :chrome)
# end

if %w[false FALSE 0].include? ENV['headless']
  Capybara.register_driver :headless_chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
        args: %w[headless enable-features=NetworkService,NetworkServiceInProcess]
      }
    )

    Capybara::Selenium::Driver.new app,
                                   browser: :chrome,
                                   desired_capabilities: capabilities
  end

  Capybara.default_driver = :headless_chrome
  Capybara.javascript_driver = :headless_chrome
end
