# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserChampionshipStat do
  it { is_expected.to belong_to :championship }

  describe '#burn_player_if_needed' do
    let(:championship_group) { create(:championship_group) }
    let(:championship1) { create(:championship) }
    let(:championship2) { create(:championship) }

    let(:user) { create(:user) }
    let(:user_championship_stat1) { create(:user_championship_stat, championship: championship1, user:) }
    let(:user_championship_stat2) { create(:user_championship_stat, championship: championship2, user:) }

    before do
      championship_group.add_championship(championship1, index: 1)
      championship_group.add_championship(championship2, index: 3)

      championship1.matches << create_list(:match, 11)
      championship2.matches << create_list(:match, 6)
    end

    it 'does not burn the player if he has not played enough matches' do
      expect { user_championship_stat1.update(match_played: 5) }.not_to(change { championship2.burned?(user) })
    end

    it 'burns the player if he has played enough matches' do
      expect { user_championship_stat1.update(match_played: 6) }.to(change { championship2.burned?(user) }.from(false).to(true))
    end

    it 'does not burn the player for higger teams' do
      expect { user_championship_stat2.update(match_played: 6) }.not_to(change { championship1.burned?(user) })
    end
  end
end
