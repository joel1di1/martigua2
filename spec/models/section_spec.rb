require 'rails_helper'

RSpec.describe Section, :type => :model do
  it { should validate_presence_of :club }
  it { should validate_presence_of :name }
  it { should have_many :teams }
  it { should have_many :participations }
  it { should have_many :users }

  let(:section) { create :section }

  describe '#add_player!' do 
    let(:user) { create :user }

    subject { section.add_player!(user) }

    context 'with a new player' do
      it { expect(subject.players).to match_array([user]) }
    end

    context 'with an already player' do
      before { section.add_player!(user) }

      it { expect(subject.players).to match_array([user]) }
    end

    context 'with an already coach' do
      before { section.add_coach!(user) }

      it { expect(subject.players).to match_array([user]) }
      it { expect(subject.coachs).to match_array([user]) }
    end
  end

  describe '#add_coach!' do 
    let(:user) { create :user }

    subject { section.add_coach!(user) }

    context 'with a new player' do
      it { expect(subject.coachs).to match_array([user]) }
    end

    context 'with an already player' do
      before { section.add_coach!(user) }

      it { expect(subject.coachs).to match_array([user]) }
    end

    context 'with an already coach' do
      before { section.add_player!(user) }

      it { expect(subject.players).to match_array([user]) }
      it { expect(subject.coachs).to match_array([user]) }
    end
  end

  describe '.invite_user!' do
    let(:params) { attributes_for :user }

    it { expect{section.invite_user!(params)}.to change{SectionUserInvitation.count}.by(1) }
    it { expect{section.invite_user!(params)}.to change{section.section_user_invitations(true).count}.by(1) }

    context 'with new user' do
      it { expect{section.invite_user!(params)}.to change{User.count}.by(1) }
    end
    context 'with already known user' do
      before { User.create!(params) }
      it { expect{section.invite_user!(params)}.to change{User.count}.by(0) }
    end
  end

end
