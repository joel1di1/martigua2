# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserChampionshipStat do
  it { is_expected.to belong_to :championship }

  describe '#burn_player_if_needed with phases (same competition_key)' do
    let(:competition_key) { '16-ans-masculins-division-2-28786' }
    let(:season) { Season.current }
    let(:phase1) { create(:championship, season:, ffhb_key: "2025-2026-21 departemental #{competition_key} 70491 111") }
    let(:playoffs) { create(:championship, season:, ffhb_key: "2025-2026-21 departemental #{competition_key} 83158 222") }
    let(:lower_championship) { create(:championship, season:) }
    let(:group) { create(:championship_group) }
    let(:user) { create(:user) }

    before do
      group.add_championship(phase1, index: 0)
      group.add_championship(playoffs, index: 0)
      group.add_championship(lower_championship, index: 1)

      phase1.matches << create_list(:match, 8)
      playoffs.matches << create_list(:match, 4)
    end

    it 'does not burn when combined stats are below threshold (5/12 < 6)' do
      create(:user_championship_stat, championship: phase1, user:, match_played: 3)
      expect do
        create(:user_championship_stat, championship: playoffs, user:, match_played: 2)
      end.not_to(change { lower_championship.reload.burned?(user) })
    end

    it 'burns when combined stats reach threshold (6/12 = 6)' do
      create(:user_championship_stat, championship: phase1, user:, match_played: 4)
      expect do
        create(:user_championship_stat, championship: playoffs, user:, match_played: 2)
      end.to(change { lower_championship.reload.burned?(user) }.from(false).to(true))
    end
  end

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

      championship1.matches << create_list(:match, nb_matches_in_championship)
      championship2.matches << create_list(:match, nb_matches_in_championship)
    end

    describe 'with 11 matches in championship' do
      let(:nb_matches_in_championship) { 11 }

      it 'does not burn the player if he has not played enough matches' do
        expect { user_championship_stat1.update(match_played: 5) }.not_to(change { championship2.reload.burned?(user) })
      end

      it 'burns the player if he has played enough matches' do
        expect { user_championship_stat1.update(match_played: 6) }.to(change do
                                                                        championship2.reload.burned?(user)
                                                                      end.from(false).to(true))
      end

      it 'does not burn the player for higger teams' do
        expect { user_championship_stat2.update(match_played: 6) }.not_to(change { championship1.reload.burned?(user) })
      end
    end

    describe 'with 12 matches in championship' do
      let(:nb_matches_in_championship) { 12 }

      it 'does not burn the player if he has not played enough matches' do
        expect { user_championship_stat1.update(match_played: 5) }.not_to(change { championship2.reload.burned?(user) })
      end

      it 'burns the player if he has played enough matches' do
        expect { user_championship_stat1.update(match_played: 6) }.to(change do
                                                                        championship2.reload.burned?(user)
                                                                      end.from(false).to(true))
      end

      it 'does not burn the player for higger teams' do
        expect { user_championship_stat2.update(match_played: 6) }.not_to(change { championship1.reload.burned?(user) })
      end
    end
  end
end
