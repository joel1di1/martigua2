# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  it { is_expected.to belong_to :season }
  it { is_expected.to belong_to :section }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to have_many :group_memberships }
  it { is_expected.to have_many(:users).through(:group_memberships) }
  it { is_expected.to have_many(:group_trainings) }
  it { is_expected.to have_many(:trainings).through(:group_trainings) }

  describe 'add_user!' do
    context 'with new user' do
      it { expect(group.add_user!(user).users).to include(user) }
      it { expect { group.add_user!(user) }.to change { group.users.count }.by(1) }
    end

    context 'with already added user' do
      before { group.add_user!(user) }

      it { expect(group.add_user!(user).users).to include(user) }
      it { expect { group.add_user!(user) }.not_to(change { group.users.count }) }
    end
  end
end
