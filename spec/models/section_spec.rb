# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Section, type: :model do
  let(:section) { create :section }

  it { should validate_presence_of :club }
  it { should validate_presence_of :name }
  it { should have_many :teams }
  it { should have_many :participations }
  it { should have_many :users }
  it { should have_and_belong_to_many :trainings }
  it { should have_many :groups }

  describe '#add_player!' do
    subject { section.add_player!(user) }

    let(:user) { create :user }

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
    subject { section.add_coach!(user) }

    let(:user) { create :user }

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
    let(:params) { user_params.merge(roles: roles) }

    let(:invite_user) { section.invite_user!(params, coach) }

    context 'with coach' do
      let!(:coach) do
        user = create :user
        section.add_coach! user
        user
      end

      it { expect { invite_user }.to change(SectionUserInvitation, :count).by(1) }
      it { expect { invite_user }.to change { section.section_user_invitations.reload.count }.by(1) }

      context 'invite player' do
        let(:roles) { Participation::PLAYER }

        it 'add user as a section player' do
          user = invite_user
          expect(user.is_player_of?(section)).to eq true
        end
      end

      context 'with new user' do
        it { expect { invite_user }.to change(User, :count).by(1) }
      end

      context 'with already known user' do
        before { User.create!(user_params) }

        it { expect { invite_user }.to change(User, :count).by(0) }
      end
    end

    context 'with fake coach' do
      let!(:coach) do
        user = create :user
        section.add_player! user
        user
      end

      it { expect { invite_user }.to raise_exception "Inviter (#{coach.email}) is not coach of #{section}" }
    end
  end

  describe '#next_trainings' do
    let!(:previous_training) { create :training, with_section: section, start_datetime: 1.week.ago }
    let!(:training_3_week_from_now) { create :training, with_section: section, start_datetime: 3.weeks.from_now }
    let!(:training_1_week_from_now) { create :training, with_section: section, start_datetime: 1.week.from_now }

    it { expect(section.next_trainings).to eq [training_1_week_from_now] }
  end

  describe '.create' do
    let(:section) { create :section }

    describe '#group_everybody' do
      let(:group_everybody) { section.group_everybody }

      it { expect(group_everybody).not_to be_nil }
      it { expect(group_everybody.name).to eq 'TOUS LES MEMBRES' }
      it { expect(group_everybody.system).to be_truthy }
      it { expect(group_everybody.role).to eq 'everybody' }
    end

    describe '#group_everyplayers' do
      let(:group_every_players) { section.group_every_players }

      it { expect(group_every_players).not_to be_nil }
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
    let(:group) { create :group, section: section }
    let(:remove_user!) { section.remove_member!(user) }

    context 'with user in section' do
      before do
        section.add_player! user
        group.add_user! user
        remove_user!
      end

      it { expect(section.users).not_to include(user) }
      it { expect(section.group_everybody.users).not_to include(user) }
      it { expect(section.group_every_players.users).not_to include(user) }
      it { expect(group.users.reload).not_to include(user) }
    end

    context 'with user in section for a specific season' do
      let(:other_season) { create :season, start_date: 2.years.ago }

      before do
        section.add_player! user, season: other_season
        section.add_player! user
        remove_user!
      end

      it { expect(section.group_everybody.users).not_to include(user) }
      it { expect(section.group_every_players.users).not_to include(user) }
      it { expect(section.group_everybody(season: other_season).users).to include(user) }
      it { expect(section.group_every_players(season: other_season).users).to include(user) }
    end
  end

  describe '#championships' do
    let(:team_1) { create :team, with_section: section }
    let(:team_2) { create :team, with_section: section }

    let(:championship_1) { create :championship }
    let(:championship_2) { create :championship }
    let(:championship_3) { create :championship }

    before do
      championship_1.enroll_team!(team_1)
      championship_2.enroll_team!(team_1)
      championship_2.enroll_team!(team_2)
    end

    it { expect(section.championships).to match_array([championship_1, championship_2]) }
  end

  describe '#members' do
    let(:current_season) { Season.current }
    let(:previous_season) { current_season.previous }

    let(:current_season_members) do
      Array.new(5) do
        u = create :user
        section.add_player!(u, season: current_season)
        u
      end
    end
    let(:previous_season_members) do
      Array.new(6) do
        u = create :user
        section.add_player!(u, season: previous_season)
        u
      end
    end

    context 'without specify season' do
      subject { section.members }

      it { is_expected.to match_array current_season_members }
    end

    context 'with specified season' do
      subject { section.members(season: previous_season) }

      it { is_expected.to match_array previous_season_members }
    end
  end

  describe '#next_duties_for' do
    subject(:next_duties) { section.next_duties_for(task) }

    let(:task) { DutyTask::TASKS.keys.sample }

    context 'with duties taks accomplished' do
      it {
        user_1, user_2, user_3, user_4, old_user = create_list :user, 5, with_section: section
        user_1.realised_task!(task, 1.day.ago)
        user_2.realised_task!(task, 2.days.ago)
        user_3.realised_task!(task, 3.days.ago)
        user_4.realised_task!(task, 4.days.ago)
        user_4.realised_task!(task, 5.days.ago)

        old_user.participations.update_all(season_id: create(:season, start_date: 3.years.ago).id)

        expect(next_duties).to match_array([user_4, user_3, user_2])
      }
    end

    context 'with one users who never did any' do
      it {
        user_1, user_2, user_3, user_4 = create_list :user, 4, with_section: section
        user_1.realised_task!(task, 1.day.ago)
        user_2.realised_task!(task, 2.days.ago)
        user_3.realised_task!(task, 3.days.ago)

        expect(next_duties).to match_array([user_4, user_3, user_2])
      }
    end
  end
end
