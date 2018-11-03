require "rails_helper"

describe SelectionsController, type: :controller do
  let(:section) { create :section }
  let(:coach) { create :user, with_section_as_coach: section }
  let(:day) { create :day }
  let(:match_1) { create :match, day: day }
  let(:match_2) { create :match, day: day }
  let(:match_3) { create :match, day: day }
  let(:matches_with_teams) { double }

  before { sign_in coach }

  describe "GET index" do
    let(:request_params) { { section_id: section.to_param, day_id: day.id } }
    let(:request) { get :index, params: request_params }

    describe "assigns" do
      before do
        expect(Team).to receive(:team_with_match_on).with(day, section).and_return(matches_with_teams)
        request
      end

      it { expect(assigns[:day]).to eq day }
      it { expect(assigns[:teams_with_matches]).to eq matches_with_teams }
    end
  end

  describe "DELETE destroy" do
    subject { delete :destroy, params: request_params }

    let(:match) { create :match, day: day }
    let(:selection) { create :selection, match: match }
    let(:request_params) { { section_id: section.to_param, match_id: match.id, id: selection.id } }

    it { expect(subject).to redirect_to(root_path) }
    it { expect(subject && Selection.find_by_id(selection.id)).to be_nil }
  end
end
