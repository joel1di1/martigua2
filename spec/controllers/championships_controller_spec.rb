require "rails_helper"

describe ChampionshipsController, :type => :controller do

  let(:championships) { create :championships }
  let(:section) { create :section }
  let(:user) { create :user, with_section_as_coach: section }

  describe "GET new" do
    let(:do_request) { get :new, section_id: section }

    before { sign_in user }

    describe 'response' do
      before { do_request }

      it { expect(response).to have_http_status(:success) }
      it { expect(assigns(:championship)).not_to be_nil}
    end
  end

  describe "POST create" do
    let(:championship_params) { {name: Faker::Company.name} }
    let(:params) { {section_id: section.to_param, championship: championship_params} }
    let(:do_request) { post :create, params }

    before { sign_in user }

    describe 'response' do
      before { do_request }

      it { expect(response).to redirect_to(section_championship_path(section, Championship.last)) }
    end

  end

end