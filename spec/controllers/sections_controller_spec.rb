# frozen_string_literal: true

require 'rails_helper'

describe SectionsController do
  let(:club) { create(:club) }
  let(:user) { create(:user) }
  let(:section) { create(:section, club:) }

  describe 'GET new' do
    let(:do_request) do
      get :new, params: { club_id: club.to_param, user_email: user.email, user_token: user.authentication_token }
    end

    before { do_request }

    it { expect(response).to have_http_status(:success) }
    it { expect(assigns(:section).club).to eq(club) }
  end

  describe 'POST create' do
    let(:section_attributes) { attributes_for(:section, club: nil) }

    let(:auth_params) do
      { club_id: club.to_param, user_email: user.email, user_token: user.authentication_token, format: :json }
    end
    let(:req_params) { auth_params.merge(section: section_attributes) }

    let(:do_request) { post :create, params: req_params }

    before { do_request }

    it { expect(response).to have_http_status(:created) }
    it { expect(user).to be_coach_of(Section.where(club:, name: section_attributes[:name])) }
  end

  describe 'GET show' do
    before do
      sign_in user
      get :show, params: { id: section.to_param }
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(assigns[:next_trainings]).to be }
  end

  describe '#suggested_user_stat' do
    let(:player) { create(:user, first_name: 'John', last_name: 'Doe') }
    let(:user_stats) do
      [
        create(:user_championship_stat, first_name: 'John', last_name: 'Doe'),
        create(:user_championship_stat, first_name: 'Jane', last_name: 'Doe'),
        create(:user_championship_stat, first_name: 'John', last_name: 'Smith')
      ]
    end

    it 'returns the user_stat with the same name as the player' do
      suggested_user_stat = described_class.new.send(:suggested_user_stat, player, user_stats)
      expect(suggested_user_stat.first_name).to eq('John')
      expect(suggested_user_stat.last_name).to eq('Doe')
    end

    it 'returns the user_stat with the most similar name to the player' do
      player = create(:user, first_name: 'John', last_name: 'Smith')
      suggested_user_stat = described_class.new.send(:suggested_user_stat, player, user_stats)
      expect(suggested_user_stat.first_name).to eq('John')
      expect(suggested_user_stat.last_name).to eq('Smith')
    end

    it 'returns nil if no user_stat has a similar name to the player' do
      player = create(:user, first_name: 'Alice', last_name: 'Johnson')
      suggested_user_stat = described_class.new.send(:suggested_user_stat, player, user_stats)
      expect(suggested_user_stat).to be_nil
    end
  end
end
