# frozen_string_literal: true

# Usage: define a `do_request` let and a `section` let in the including context.
#
#   describe 'GET index' do
#     let(:do_request) { get section_trainings_path(section) }
#
#     it_behaves_like 'an endpoint denied to non-members of the section'
#   end
RSpec.shared_examples 'an endpoint denied to non-members of the section' do
  context 'when signed in as a member of another section' do
    let(:other_section) { create(:section) }
    let(:non_member) { create(:user, with_section: other_section) }

    before do
      sign_in non_member, scope: :user
      do_request
    end

    it { expect(response).to have_http_status(:forbidden) }
  end
end
