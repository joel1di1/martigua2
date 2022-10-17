# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: [:system, :feature, :devise]) do
    if true || ENV['SHOW_BROWSER'] == 'true'
      driven_by :selenium_chrome
    else
      driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
    end
  end
end
