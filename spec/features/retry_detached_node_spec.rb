# frozen_string_literal: true

describe RetryDetachedNode do
  subject(:node) { Capybara::Node::Base.allocate }

  let(:unknown_error) { Selenium::WebDriver::Error::UnknownError }

  it 'retries the chromedriver detached-node error' do
    error = unknown_error.new('unhandled inspector error: Node with given id does not belong to the document')
    expect(node.send(:catch_error?, error, [])).to be true
  end

  it 'does not retry other UnknownErrors' do
    expect(node.send(:catch_error?, unknown_error.new('something else'), [])).to be false
  end
end
