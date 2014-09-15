require "rails_helper"

describe MatchesController, :type => :controller do

  let(:section) { create :section }
  let(:user) { create :user, with_section: section }
  let(:championship) { create :championship }

  before { sign_in user }

  describe 'GET new' do
    let(:do_request) { get :new, section_id: section, championship_id: championship }
    before { do_request }

    it { expect(response).to have_http_status(:success) }
    it { expect(assigns[:match]).not_to be_nil }
  end

end