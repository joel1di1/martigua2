require "rails_helper"

describe UsersController, :type => :controller do

  describe "GET index" do
    let(:request_params) { {} }
    let(:request) { get :index, request_params }

    context 'within section' do
      let(:section) { create :section }
      let(:request_params) { { section_id: section.to_param } }

      context 'sign as user with only one section' do
        let(:user) { create :user }

        before { 
          section.add_player!(user)
          sign_in user
        }
        
        before { request }

        it { expect(assigns[:users]).to match_array([user]) }
      end
    end
  end
end