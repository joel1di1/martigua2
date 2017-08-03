require "rails_helper"

describe GroupsController, :type => :controller do

  let(:section) { create :section }
  let(:user) { create :user, with_section: section }
  let(:group) { create :group, section: section }

  before { sign_in user }

  describe 'POST add_users' do
    let(:do_request) { post :add_users, params: { section_id: section.to_param, group_id: group.to_param, user_id: user.id } }

    it { expect{do_request}.to change{group.users.count}.by(1) }

    describe 'method call' do
      before do
        expect(User).to receive(:find).with(user.id.to_s).and_return(user)
        expect(Group).to receive(:find).with(group.to_param).and_return(group)
        expect(group).to receive(:add_user!).with(user)

        do_request
      end

      it { expect(response).to redirect_to(section_group_path(section, group)) }
    end
  end

  describe 'POST create' do
    let(:do_request) { post :create, params: { section_id: section.to_param, group: new_group_attributes } }

    context 'with correct attributes' do
      let(:new_group_attributes) { attributes_for(:group, section: nil) }

      it { expect{ do_request }.to change{ Group.count }.by(1) }

      describe 'redirection' do
        before { do_request }

        it { expect(response).to redirect_to(section_group_path(section, Group.last)) }
      end
    end

    context 'with empty name' do
      let(:new_group_attributes) { attributes_for(:group, section: nil, name: nil) }

      it { expect{do_request}.to change{Group.count}.by(0) }

      describe 'redirection' do
        before { do_request }

        it { expect(response).to have_http_status(:success) }
      end
    end
  end

end