require "rails_helper"

describe SectionsController, :type => :controller do
  let(:club) { create :club }
  let(:user) { create :user }
  let(:section) { create :section, club: club }

  describe "GET new" do
    let(:do_request) { get :new, params: { club_id: club.to_param, user_email: user.email, user_token: user.authentication_token } }

    before { do_request }

    it { expect(response).to have_http_status(:success) }
    it { expect(assigns(:section).club).to eq(club) }
  end

  describe "POST create" do
    let(:section_attributes) { attributes_for(:section, club: nil) }

    let(:auth_params) { { club_id: club.to_param, user_email: user.email, user_token: user.authentication_token, format: :json } }
    let(:req_params) { auth_params.merge({ section: section_attributes }) }

    let(:do_request) { post :create, params: req_params }

    before { do_request }

    it { expect(response).to have_http_status(:created) }
    it { expect(user.is_coach_of?(Section.where(club: club, name: section_attributes[:name]))).to be_truthy }
  end

  describe 'GET show' do
    before do
      sign_in user
      expect_any_instance_of(Section).to receive(:next_trainings).and_return(:next_trainings_mock)
      get :show, params: { id: section.to_param }
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(assigns[:next_trainings]).to eq :next_trainings_mock }
  end
end
