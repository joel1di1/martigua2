# frozen_string_literal: true

module Ffhb
  module Mock
    def mock_ffhb
      # mock for 2023 ffhb version
      mocks_path = Rails.root.join('spec/fixtures/ffhb/2023')
      filenames = Dir.each_child(mocks_path)
      #select json files only
      filenames = filenames.select{|filename| filename.match(/\.json$/)}
      filenames.each do |filename|
        case filename
        when /fetch_comite_details_(\d+).json/
          comite_id = $1.to_i
          allow(FfhbService.instance).to receive(:fetch_comite_details).with(comite_id) do
            file_content = File.read(mocks_path.join(filename))
            Oj.load(file_content)
          end
        when /fetch_competition_details_(\d+).json/
        else
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Ffhb::Mock
end
