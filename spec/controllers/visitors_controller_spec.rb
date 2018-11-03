require "rails_helper"

describe VisitorsController, :type => :controller do
  describe "GET index" do
    context 'not signed in' do
      before { get :index }

      it { expect(response.status).to eq(200) }
      it { expect(response).to render_template('index') }
    end

    context 'sign as user with only one section' do
      let(:user) { create :one_section_player }

      before do
        sign_in user

        get :index
      end

      it { expect(response).to redirect_to(section_path(user.sections.first)) }
    end
  end
end
