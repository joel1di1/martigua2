# frozen_string_literal: true

require 'rails_helper'

describe 'Selections' do
  let(:section) { create(:section) }
  let(:coach) { create(:user, with_section_as_coach: section) }
  let(:day) { create(:day) }

  before { sign_in coach, scope: :user }

  describe 'GET index' do
    let(:request) { get section_day_selections_path(section_id: section.to_param, day_id: day.id) }

    describe 'response' do
      before do
        request
      end

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'DELETE destroy' do
    subject(:do_delete) do
      delete section_selection_path(section_id: section.to_param, match_id: match.id, id: selection.id)
    end

    let(:match) { create(:match, day:) }
    let(:selection) { create(:selection, match:) }

    it { expect(do_delete).to redirect_to(root_path) }
    it { expect(do_delete && Selection.find_by(id: selection.id)).to be_nil }
  end
end
