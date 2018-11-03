require 'rails_helper'

RSpec.describe Club, :type => :model do
  let(:club) { create :club }

  it { should validate_presence_of :name }
  it { should have_many :sections }

  describe '#add_admin!' do
    let(:user) { create :user }

    context 'with new user' do
      describe 'user admin of' do
        before { club.add_admin!(user) }

        it { expect(user.is_admin_of?(club)).to be_truthy }
      end

      describe 'club admins count' do
        it { expect { club.add_admin!(user) }.to change { club.admins.count }.by(1) }
      end
    end

    context 'with user already admin' do
      before { club.add_admin!(user) }

      before { club.add_admin!(user) }

      it { expect(user.is_admin_of?(club)).to be_truthy }
      it { expect { club.add_admin!(user) }.not_to change { club.admins.count } }
    end
  end
end
