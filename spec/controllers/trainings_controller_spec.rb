require "rails_helper"

describe TrainingsController, :type => :controller do

  describe "GET index" do
    let(:request_params) { {} }
    let(:request) { get :index, request_params }

    context 'within section' do
      let(:section) { create :section }
      let(:request_params) { { section_id: section.to_param } }

      context 'signed as user' do
        let(:user) { create :user, with_section: section }

        let(:training_1) { create :training, with_section: section }
        let(:training_2) { create :training, with_section: section }
        let!(:training_not_in_section) { create :training }

        before { sign_in user }
        before { request }

        it { expect(assigns[:trainings]).to match_array([training_1, training_2 ]) }
      end
    end
  end
end