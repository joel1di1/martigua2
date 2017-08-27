require "rails_helper"

describe CalendarsController, type: :controller do

  let(:section) { create :section }
  let(:user) { create :user, with_section_as_coach: section }

  before { sign_in user }

  describe "GET index" do
    let!(:calendar_1) { create :calendar }
    let!(:calendar_2) { create :calendar }

    let(:do_request) { get :index, params: { section_id: section.to_param } }

    before { do_request }

    it { expect(response).to have_http_status(:success) }
    it { expect(assigns(:calendars)).to match_array([calendar_1, calendar_2])}
  end

  describe "GET edit" do
    let(:calendar) { create :calendar }
    let(:do_request) { get :edit, params: { section_id: section.to_param, id: calendar.id } }

    before { do_request }

    it { expect(response).to have_http_status(:success) }
    it { expect(assigns(:calendar)).to eq calendar }
  end

end
