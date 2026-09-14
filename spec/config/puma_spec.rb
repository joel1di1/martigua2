# frozen_string_literal: true

require 'rails_helper'
require 'puma/configuration'
require 'puma/plugin/solid_queue'

# Tests the puma config file itself, not a class.
# rubocop:disable-next RSpec/DescribeClass
RSpec.describe 'config/puma.rb' do
  def load_puma_config
    configuration = Puma::Configuration.new(config_files: [puma_config_path])
    configuration.load
    configuration.clamp
    configuration.options
  end

  def with_rails_env(value)
    original = ENV.fetch('RAILS_ENV', nil)
    ENV['RAILS_ENV'] = value
    load_puma_config
  ensure
    ENV['RAILS_ENV'] = original
  end

  def puma_config_path
    File.expand_path('../../config/puma.rb', __dir__)
  end

  # Heroku boots `bundle exec puma -C config/puma.rb` before any Rails require:
  # simulate that by hiding the Rails constant while the file is evaluated.
  around do |example|
    # Hiding Rails is the point: stub_const cannot undefine a constant.
    # rubocop:disable RSpec/RemoveConst
    rails = Object.send(:remove_const, :Rails)
    # rubocop:enable RSpec/RemoveConst
    example.run
  ensure
    Object.const_set(:Rails, rails)
  end

  it 'loads without Rails, as the standalone puma on Heroku does' do
    expect { load_puma_config }.not_to raise_error
  end

  it 'runs the queue in async mode in every environment' do
    expect(with_rails_env('development')[:solid_queue_mode]).to eq(:async)
    expect(with_rails_env('production')[:solid_queue_mode]).to eq(:async)
  end
end
