# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Club, type: :model do
  let(:club) { create :club }

  it { should validate_presence_of :name }
  it { should have_many :sections }

  describe '#add_admin!' do
    let(:user) { create :user }

    context 'with new user' do
      describe 'user admin of' do
        before { club.add_admin!(user) }

        it { expect(user).to be_is_admin_of(club) }
      end

      describe 'club admins count' do
        it { expect { club.add_admin!(user) }.to change { club.admins.count }.by(1) }
      end
    end

    context 'with user already admin' do
      before do
        club.add_admin!(user)
        club.add_admin!(user)
      end

      it { expect(user).to be_is_admin_of(club) }
      it { expect { club.add_admin!(user) }.not_to(change { club.admins.count }) }
    end
  end
end
