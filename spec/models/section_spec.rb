require 'rails_helper'

RSpec.describe Section, :type => :model do
  it { should validate_presence_of :club }
  it { should validate_presence_of :name }
  it { should have_many :teams }
  it { should have_many :participations }
  it { should have_many :users }
  it { should have_and_belong_to_many :trainings }

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
    let(:user_params) { attributes_for(:user) }
    let(:roles) { [Participation::PLAYER, Participation::COACH].sample }
    let(:params) { user_params.merge({roles: roles}) }

    let(:invite_user) { section.invite_user!(params, coach) }

    context 'with coach' do
      let!(:coach) do
        user = create :user
        section.add_coach! user
        user
      end
  
      it { expect{ invite_user }.to change{SectionUserInvitation.count}.by(1) }
      it { expect{ invite_user }.to change{section.section_user_invitations(true).count}.by(1) }

      context 'invite player' do
        let(:roles) { Participation::PLAYER }
        it 'add user as a section player' do
          user = invite_user
          expect(user.is_player_of?(section)).to eq true
        end
      end

      context 'with new user' do
        it { expect{ invite_user }.to change{User.count}.by(1) }
      end
      context 'with already known user' do
        before { User.create!(user_params) }
        it { expect{ invite_user }.to change{User.count}.by(0) }
      end
    end

    context 'with fake coach' do
      let!(:coach) do
        user = create :user
        section.add_player! user
        user
      end

      it { expect{ invite_user }.to raise_exception }
    end
  end

end
