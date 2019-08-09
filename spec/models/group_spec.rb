# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, :type => :model do
  let(:user) { create :user }
  let(:group) { create :group }

  it { should belong_to :season }
  it { should validate_presence_of :season }
  it { should validate_presence_of :name }
  it { should validate_presence_of :section }
  it { should have_and_belong_to_many :users }
  it { should have_and_belong_to_many :trainings }

  describe 'add_user!' do
    context 'with new user' do
      it { expect(group.add_user!(user).users).to include(user) }
      it { expect { group.add_user!(user) }.to change { group.users.count }.by(1) }
    end

    context 'with already added user' do
      before { group.add_user!(user) }

      it { expect(group.add_user!(user).users).to include(user) }
      it { expect { group.add_user!(user) }.to change { group.users.count }.by(0) }
    end
  end
end
