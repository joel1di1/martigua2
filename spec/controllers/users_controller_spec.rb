require "rails_helper"

describe UsersController, :type => :controller do

  describe "GET index" do
    let(:request_params) { {} }
    let(:request) { get :index, request_params }

    context 'within section' do
      let(:section) { create :section }
      let(:request_params) { { section_id: section.to_param } }

      context 'with on user' do
        let(:user) { create :user, with_section: section }

        before { sign_in user and request }

        it { expect(assigns[:users]).to match_array([user]) }
      end

      context 'with one user with several roles' do
        let(:user) do 
          user = create :user, with_section_as_coach: section
          section.add_player! user
          user
        end
        
        before { sign_in user and request }

        it { expect(assigns[:users]).to match_array([user]) }
      end

    end
  end
end