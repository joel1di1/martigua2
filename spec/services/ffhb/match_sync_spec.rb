# frozen_string_literal: true

RSpec.describe Ffhb::MatchSync do
  describe '#call when the FFHB fetch fails' do
    subject(:sync) { Ffhb::MatchSync.new(match).call }

    let(:match) { build_stubbed(:match, ffhb_key: 'some-competition 191104 2644283') }
    let(:ffhb_service) { instance_double(FfhbService) }

    before do
      allow(FfhbService).to receive(:instance).and_return(ffhb_service)
      allow(ffhb_service).to receive(:fetch_match_details).and_raise(error)
    end

    context 'with a 5xx (FFHB temporarily down)' do
      let(:error) { FfhbServiceError.new('HTTP 502 for URL: x', status: 502) }

      it 'does not report a possibly deleted match to Sentry' do
        expect(Sentry).not_to receive(:capture_message)
        sync
      end
    end

    context 'with a 404 (match gone)' do
      let(:error) { FfhbServiceError.new('HTTP 404 for URL: x', status: 404) }

      before { allow(match).to receive(:championship).and_return(build_stubbed(:championship)) }

      it 'reports a possibly deleted match to Sentry' do
        expect(Sentry).to receive(:capture_message).with(/possibly deleted match/, hash_including(level: :warning))
        sync
      end
    end
  end
end
