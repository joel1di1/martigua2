# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchAvailabilitySummary do
  subject(:summary) do
    MatchAvailabilitySummary.new(player_ids:, availability_rows:, away_user_ids:)
  end

  let(:player_ids) { [1, 2, 3, 4, 5] }
  let(:availability_rows) { [[1, true], [2, true], [3, false]] }
  let(:away_user_ids) { [] }

  it 'splits players between available, not available and no response' do
    expect(summary.counts).to eq(available: 2, not_available: 1, no_response: 2)
  end

  context 'when an available player is away' do
    let(:away_user_ids) { [2] }

    it 'moves the player from available to not available' do
      expect(summary.counts).to eq(available: 1, not_available: 2, no_response: 2)
    end
  end

  context 'when a player marked not available is also away' do
    let(:away_user_ids) { [3] }

    it 'does not double-count the player' do
      expect(summary.counts).to eq(available: 2, not_available: 1, no_response: 2)
    end
  end

  context 'when a player without response is away' do
    let(:away_user_ids) { [4] }

    it 'counts the player as not available, not as no response' do
      expect(summary.counts).to eq(available: 2, not_available: 2, no_response: 1)
    end
  end

  context 'when the same user appears twice in away ids' do
    let(:away_user_ids) { [4, 4] }

    it 'counts the user once' do
      expect(summary.counts).to eq(available: 2, not_available: 2, no_response: 1)
    end
  end
end
