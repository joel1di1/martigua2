require "rails_helper"

describe GroupsController, :type => :controller do

  let(:section) { create :section }
  let(:user) { create :user, with_section: section }
  let(:group) { create :group, section: section }

  describe 'POST add_users' do
    before { sign_in user }

    let(:do_request) { post :add_users, section_id: section.to_param, group_id: group.to_param, user_id: user.id }

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

end