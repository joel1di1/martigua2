require 'rails_helper'

RSpec.describe Section, :type => :model do
  it { should validate_presence_of :club }
  it { should validate_presence_of :name }
  it { should have_many :teams }
  it { should have_many :participations }
  it { should have_many :users }
  it { should have_and_belong_to_many :trainings }
  it { should have_many :groups }

  let(:section) { create :section }

  describe '#add_player!' do 
    let(:user) { create :user }

    subject { section.add_player!(user) }

    context 'with a new player' do
      it { expect(subject.players).to match_array([user]) }
      it { expect(subject.group_everybody.users).to match_array([user]) }
      it { expect(subject.group_every_players.users).to match_array([user]) }
    end

    context 'with an already player' do
      before { section.add_player!(user) }

      it { expect(subject.players).to match_array([user]) }
      it { expect(subject.group_everybody.users).to match_array([user]) }
      it { expect(subject.group_every_players.users).to match_array([user]) }
    end

    context 'with an already coach' do
      before { section.add_coach!(user) }

      it { expect(subject.players).to match_array([user]) }
      it { expect(subject.coachs).to match_array([user]) }
      it { expect(subject.group_everybody.users).to match_array([user]) }
      it { expect(subject.group_every_players.users).to match_array([user]) }
    end
  end

  describe '#add_coach!' do 
    let(:user) { create :user }

    subject { section.add_coach!(user) }

    context 'with a new user' do
      it { expect(subject.coachs).to match_array([user]) }

      it { expect(subject.group_everybody.users).to match_array([user]) }
      it { expect(subject.group_every_players.users).to match_array([]) }      
    end

    context 'with an already coach' do
      before { section.add_coach!(user) }

      it { expect(subject.coachs).to match_array([user]) }

      it { expect(subject.group_everybody.users).to match_array([user]) }
      it { expect(subject.group_every_players.users).to match_array([]) }      
    end

    context 'with an already player' do
      before { section.add_player!(user) }

      it { expect(subject.players).to match_array([user]) }
      it { expect(subject.coachs).to match_array([user]) }

      it { expect(subject.group_everybody.users).to match_array([user]) }
      it { expect(subject.group_every_players.users).to match_array([user]) }      
    end
  end

  describe '#invite_user!' do
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

  describe '#next_trainings' do
    let!(:previous_training) { create :training, with_section: section, start_datetime: 1.week.ago }
    let!(:training_2_week_from_now) { create :training, with_section: section, start_datetime: 2.weeks.from_now }
    let!(:training_1_week_from_now) { create :training, with_section: section, start_datetime: 1.week.from_now }

    it { expect(section.next_trainings).to eq [training_1_week_from_now, training_2_week_from_now] }
  end

  describe '.create' do
    let(:section) { create :section }

    describe '#group_everybody' do
      let(:group_everybody) { section.group_everybody }

      it { expect(group_everybody).to_not be_nil }
      it { expect(group_everybody.name).to eq 'TOUS LES MEMBRES' }
      it { expect(group_everybody.system).to be_truthy }
      it { expect(group_everybody.role).to eq 'everybody' }
    end

    describe '#group_everyplayers' do
      let(:group_every_players) { section.group_every_players }

      it { expect(group_every_players).to_not be_nil }
      it { expect(group_every_players.name).to eq 'TOUS LES JOUEURS' }
      it { expect(group_every_players.system).to be_truthy }
      it { expect(group_every_players.role).to eq 'every_players' }
    end
  end

  describe '#has_member?' do
    let(:has_member) { section.has_member?(user) }

    context 'with user in section' do
      let(:user) { create :user, with_section: section }

      it { expect(has_member).to be_truthy }
    end

    context 'with user not in section' do
      let(:user) { create :user }

      it { expect(has_member).to be_falsy }
    end
  end

  describe '.remove_member!' do
    let(:user) { create :user }
    let(:remove_user) { section.remove_member!(user) }

    context 'with user in section' do
      before { section.add_player! user }

      before { remove_user }
      
      it { expect(section.users.include?(user)).to be_falsy }
      it { expect(section.group_everybody.users.include?(user)).to be_falsy }
      it { expect(section.group_every_players.users.include?(user)).to be_falsy }
    end
  end

  describe '#championships' do
    let(:team_1) { create :team, with_section: section }    
    let(:team_2) { create :team, with_section: section }    

    let(:championship_1) { create :championship }
    let(:championship_2) { create :championship }
    let(:championship_3) { create :championship }

    let!(:enrolled_team_championship_1) { create :enrolled_team_championship, team: team_1, championship: championship_1 }
    let!(:enrolled_team_championship_2) { create :enrolled_team_championship, team: team_2, championship: championship_2 }
    let!(:enrolled_team_championship_3) { create :enrolled_team_championship, team: team_1, championship: championship_2 }

    it { expect(section.championships).to match_array([championship_1, championship_2]) }
  end

end
