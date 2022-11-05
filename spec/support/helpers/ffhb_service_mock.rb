# frozen_string_literal: true

module Ffhb
  module Mock
    def mock_ffhb
      ['pool/110562', 'pool/123', 'competitionPool/20570'].each do |path|
        allow(FfhbService.instance).to receive(:fetch_ffhb_url).with(path) do
          File.read("spec/fixtures/ffhb/#{path.tr('/', '.')}.json")
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Ffhb::Mock
end
