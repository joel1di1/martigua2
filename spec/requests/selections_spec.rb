# frozen_string_literal: true

require 'rails_helper'

describe 'Selections' do
  let(:section) { create(:section) }
  let(:coach) { create(:user, with_section_as_coach: section) }
  let(:championship) { create(:championship) }
  let(:day) { create(:day) }

  before do
    create(:team, with_section: section, enrolled_in: championship)
    sign_in coach, scope: :user
  end

  describe 'GET index' do
    let(:do_request) { get section_day_selections_path(section_id: section.to_param, day_id: day.id) }

    context 'when the day has a match belonging to the current section' do
      let(:match) { create(:match, championship:, day:) }

      before { match }

      it 'succeeds' do
        do_request
        expect(response).to have_http_status(:success)
      end

      it 'only exposes selections from matches belonging to the current section' do
        selection = create(:selection, match:)
        other_championship = create(:championship)
        other_match = create(:match, championship: other_championship, day:)
        create(:selection, match: other_match)

        do_request
        expect(assigns(:day_selections)).to contain_exactly(selection)
      end
    end

    context 'when the day has no match belonging to the current section' do
      it 'returns not_found' do
        do_request
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:do_delete) do
      delete section_selection_path(section_id: section.to_param, match_id: match.id, id: selection.id)
    end

    let(:match) { create(:match, championship:, day:) }
    let(:selection) { create(:selection, match:) }

    it 'destroys the selection' do
      selection
      expect { do_delete }.to change(Selection, :count).by(-1)
    end

    it { expect(do_delete).to redirect_to(root_path) }

    context 'when the selection belongs to a match from another section' do
      let(:other_championship) { create(:championship) }
      let(:other_match) { create(:match, championship: other_championship) }
      let(:other_selection) { create(:selection, match: other_match) }

      it 'returns not_found and does not destroy the selection' do
        other_selection
        expect do
          delete section_selection_path(section_id: section.to_param, match_id: other_match.id, id: other_selection.id)
        end.not_to change(Selection, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
