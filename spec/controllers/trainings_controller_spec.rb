require "rails_helper"

describe TrainingsController, :type => :controller do

  describe "GET index" do
    let(:request_params) { {} }
    let(:request) { get :index, request_params }

    context 'within section' do
      let(:section) { create :section }
      let(:request_params) { { section_id: section.to_param } }

      context 'signed as user' do
        let(:user) { create :user }

        let(:training_1) { create :training }
        let(:training_2) { create :training }
        let!(:training_not_in_section) { create :training }

        before { 
          section.add_player!(user)
          section.trainings << training_1
          section.trainings << training_2
          sign_in user
        }
        
        before { request }

        it { expect(assigns[:trainings]).to match_array([training_1, training_2 ]) }
      end
    end
  end
end