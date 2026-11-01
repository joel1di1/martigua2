# frozen_string_literal: true

# chromedriver raises UnknownError "Node with given id does not belong to the document" when a page
# swap lands mid-lookup. Capybara only retries stale-element errors, so retry this exact message too
# (the node was never acted on, so retrying a click or a fill is safe). Other UnknownErrors still fail fast.
module RetryDetachedNode
  DETACHED_NODE = 'Node with given id does not belong to the document'

  def catch_error?(error, errors = nil)
    super || (error.is_a?(Selenium::WebDriver::Error::UnknownError) && error.message.include?(DETACHED_NODE))
  end
end
Capybara::Node::Base.prepend(RetryDetachedNode)

RSpec.configure do |_config|
  Capybara.register_driver :selenium_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new

    options.add_argument('--headless') if ENV['SHOW_BROWSER'].blank?
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-search-engine-choice-screen')
    options.add_argument('--window-size=1280,800')

    Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
  end

  Capybara.javascript_driver = :selenium_chrome
end
