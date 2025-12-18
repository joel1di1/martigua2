# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrefetchMatchData do
  controller(ApplicationController) do
    include PrefetchMatchData

    def index
      @section = Section.find(params[:section_id])
      @next_matches = @section.next_matches.includes(
        :local_team,
        :visitor_team,
        :day,
        :location,
        :championship,
        match_availabilities: :user
      )
      @current_user_is_player = current_user.player_of?(@section)
      preload_current_user_availabilities
      precompute_match_availability_counts
      head :ok
    end
  end

  let(:club) { create(:club) }
  let(:section) { create(:section, club:) }
  let(:user) { create(:user, with_section: section) }
  let(:player1) { create(:user, with_section: section) }
  let(:player2) { create(:user, with_section: section) }
  let(:championship) { create(:championship, season: Season.current) }
  let(:team1) { create(:team, club:, sections: [section]) }
  let(:team2) { create(:team, club:) }
  let(:day) { create(:day, period_start_date: 1.week.from_now, period_end_date: 1.week.from_now + 2.hours) }
  let!(:match1) do
    create(:match,
           championship:,
           local_team: team1,
           visitor_team: team2,
           day:,
           start_datetime: 1.week.from_now)
  end
  let!(:match2) do
    create(:match,
           championship:,
           local_team: team1,
           visitor_team: team2,
           day:,
           start_datetime: 2.weeks.from_now)
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
    sign_in user
    championship.enroll_team!(team1)
  end

  describe '#preload_match_data' do
    it 'sets @current_user_is_player' do
      get :index, params: { section_id: section.id }
      expect(assigns(:current_user_is_player)).to be true
    end

    it 'preloads current user availabilities' do
      create(:match_availability, user:, match: match1, available: true)
      get :index, params: { section_id: section.id }
      expect(assigns(:current_user_availabilities)).to be_present
      expect(assigns(:current_user_availabilities)[match1.id].available).to be true
    end

    it 'precomputes match availability counts' do
      create(:match_availability, user: player1, match: match1, available: true)
      create(:match_availability, user: player2, match: match1, available: false)

      get :index, params: { section_id: section.id }

      counts = assigns(:match_availability_counts)
      expect(counts).to be_present
      expect(counts[match1.id]).to be_present
      expect(counts[match1.id][:available]).to eq(1)
      expect(counts[match1.id][:not_available]).to eq(1)
    end

    context 'with absences' do
      let(:absent_player) { create(:user, with_section: section) }
      let!(:absence) do
        create(:absence,
               user: absent_player,
               start_at: 5.days.from_now,
               end_at: 10.days.from_now)
      end

      it 'counts absent users as not available' do
        create(:match_availability, user: absent_player, match: match1, available: true)

        get :index, params: { section_id: section.id }

        counts = assigns(:match_availability_counts)
        # Absent player should not count as available even though they marked themselves as available
        expect(counts[match1.id][:available]).to eq(0)
        expect(counts[match1.id][:not_available]).to be >= 1
      end

      it 'does not subtract absences from available count for players not marked available' do
        # Setup: 3 players total
        # - player1: marked available=true, not absent
        # - absent_player: has absence, marked available=false (or no response)
        # - player2: marked available=true, not absent
        create(:match_availability, user: player1, match: match1, available: true)
        create(:match_availability, user: player2, match: match1, available: true)
        # absent_player has no MatchAvailability (no response) but has an absence

        get :index, params: { section_id: section.id }

        counts = assigns(:match_availability_counts)
        # Should show 2 available (player1 and player2)
        # The absent_player's absence should NOT be subtracted from the available count
        # because they were never marked as available=true
        expect(counts[match1.id][:available]).to eq(2)
      end

      it 'correctly handles mix of absent available and absent unavailable players' do
        # Setup:
        # - player1: available=true, has absence -> should reduce available count
        # - player2: available=true, no absence -> should be in available count
        # - absent_player: available=false, has absence -> should NOT reduce available count
        absent_available_player = create(:user, with_section: section)
        create(:absence,
               user: absent_available_player,
               start_at: 5.days.from_now,
               end_at: 10.days.from_now)

        create(:match_availability, user: absent_available_player, match: match1, available: true)
        create(:match_availability, user: player2, match: match1, available: true)
        create(:match_availability, user: absent_player, match: match1, available: false)

        get :index, params: { section_id: section.id }

        counts = assigns(:match_availability_counts)
        # Only player2 should be counted as available (player1 is absent but was available=true, so subtracted)
        # absent_player is not_available with absence, should NOT double-count
        expect(counts[match1.id][:available]).to eq(1)
        expect(counts[match1.id][:not_available]).to be >= 2
      end
    end

    context 'with no availabilities set' do
      it 'calculates no_response count correctly' do
        get :index, params: { section_id: section.id }

        counts = assigns(:match_availability_counts)
        # All players in section should be counted as no_response
        expect(counts[match1.id][:no_response]).to eq(section.players.count)
      end
    end
  end

  describe '#preload_current_user_availabilities' do
    it 'returns empty hash when no matches' do
      Match.destroy_all
      get :index, params: { section_id: section.id }
      expect(assigns(:current_user_availabilities)).to eq({})
    end

    it 'preloads availabilities for multiple matches' do
      create(:match_availability, user:, match: match1, available: true)
      create(:match_availability, user:, match: match2, available: false)

      get :index, params: { section_id: section.id }

      availabilities = assigns(:current_user_availabilities)
      expect(availabilities[match1.id].available).to be true
      expect(availabilities[match2.id].available).to be false
    end
  end

  describe '#precompute_match_availability_counts' do
    it 'handles empty section gracefully' do
      empty_section = create(:section, club:)
      get :index, params: { section_id: empty_section.id }
      expect(assigns(:match_availability_counts)).to be_a(Hash)
    end

    it 'calculates counts for multiple matches efficiently' do
      create(:match_availability, user: player1, match: match1, available: true)
      create(:match_availability, user: player2, match: match1, available: false)
      create(:match_availability, user: player1, match: match2, available: false)

      get :index, params: { section_id: section.id }

      counts = assigns(:match_availability_counts)
      expect(counts[match1.id][:available]).to eq(1)
      expect(counts[match1.id][:not_available]).to eq(1)
      expect(counts[match2.id][:available]).to eq(0)
      expect(counts[match2.id][:not_available]).to eq(1)
    end
  end
end
