# frozen_string_literal: true

module Ffhb
  module Mock
    def mock_ffhb
      mocks_path = Rails.root.join('spec/fixtures/ffhb')
      Dir.each_child(mocks_path) do |filename|
        url_path = filename.gsub('.json', '').tr('.', '/')
        allow(FfhbService.instance).to receive(:fetch_ffhb_url).with(url_path) do
          File.read(mocks_path.join(filename))
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Ffhb::Mock
end
