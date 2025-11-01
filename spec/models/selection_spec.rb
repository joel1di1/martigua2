# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Selection do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :match }
  it { is_expected.to belong_to :team }

  describe 'create' do
    context 'with previous selection' do
      let(:day) { create(:day) }
      let(:match1) { create(:match, day:) }
      let(:match2) { create(:match, day:) }
      let(:user) { create(:user) }
      let!(:previous_selection) { create(:selection, user:, match: match1, team: match1.local_team) }

      it 'deletes old selections' do
        expect(Selection.where(user:, match: [match1, match2])).to eq [previous_selection]
        new_selection = Selection.create! user:, team: match2.local_team, match: match2
        expect(Selection.where(user:, match: [match1, match2])).to eq [new_selection]
      end
    end
  end
end
