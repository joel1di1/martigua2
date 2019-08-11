# frozen_string_literal: true

describe User do
  let(:user) { create :user }
  let(:section) { create :section }

  it { should validate_presence_of :email }
  it { should have_db_column :first_name }
  it { should have_db_column :last_name }
  it { should have_db_column :nickname }
  it { should have_db_column :phone_number }
  it { should have_many :club_admin_roles }
  it { should have_many :participations }
  it { should have_many :sections }
  it { should have_many :training_presences }
  it { should have_many :duty_tasks }
  it { should have_and_belong_to_many :groups }

  describe 'authentication token should be generated' do
    subject { create :user, authentication_token: nil }

    its(:authentication_token) { should_not be_nil }
    its(:id) { should_not be_nil }
  end

  describe '#has_only_one_section?' do
    subject { user.has_only_one_section? }

    context 'user with no section' do
      it { should eq false }
    end

    context 'user with two sections' do
      let!(:participation_1) { create :participation, user: user }
      let!(:participation_2) { create :participation, user: user }

      it { should eq false }
    end

    context 'user with one section' do
      let!(:participation_1) { create :participation, user: user }

      it { should eq true }
    end

    context 'user with two participations on one section' do
      let(:section) { create :section }
      let!(:participation_1) { create :participation, user: user, section: section, role: Participation::PLAYER }
      let!(:participation_2) { create :participation, user: user, section: section, role: Participation::COACH }

      it { should eq true }
    end
  end

  describe '#is_coach_of?' do
    subject { user.is_coach_of?(section) }

    context 'with a user not in the section' do
      it { should eq false }
    end

    context 'with a player of the section' do
      before { section.add_player!(user) }

      it { should eq false }
    end

    context 'with a coach of the section' do
      before { section.add_coach!(user) }

      it { should eq true }
    end

    context 'with a last year coach of the section' do
      let(:previous_season) { create :season, start_date: 2.years.ago }

      before { section.add_coach!(user, season: previous_season) }

      it { should be_falsy }
    end
  end

  describe '#is_player_of?' do
    subject { user.is_player_of?(section) }

    let(:section) { create :section }

    context 'with a player not in the section' do
      it { should eq false }
    end

    context 'with a player of the section' do
      before { section.add_player!(user) }

      it { should eq true }
    end

    context 'with a coach of the section' do
      before { section.add_coach!(user) }

      it { should eq false }
    end

    context 'with a last year player of the section' do
      let(:previous_season) { create :season, start_date: 2.years.ago }

      before { section.add_player!(user, season: previous_season) }

      it { should be_falsy }
    end
  end

  describe '#display_participations' do
    let(:display) { user.display_participations }

    context 'with one participation' do
      let!(:participation) { create :participation, user: user }

      it { expect(display).to include(participation.section.club.name) }
      it { expect(display).to include(participation.section.name) }
      it { expect(display).to include(participation.role) }
      it { expect(display).to include(participation.season.to_s) }
    end
  end

  describe '#present_for!' do
    context 'with one training' do
      subject(:set_presence) { user.present_for!(training) }

      let(:training) { create :training }

      it { expect { set_presence }.to change(TrainingPresence, :count).by(1) }

      describe 'user availability' do
        before { set_presence }

        it { expect(user.is_present_for?(training)).to be_truthy }
      end

      describe 'double presence set' do
        it { expect { 2.times { user.present_for!(training) } }.to change(TrainingPresence, :count).by(1) }
      end
    end

    context 'with two trainings' do
      let(:training_1) { create :training }
      let(:training_2) { create :training }

      context 'passed as array' do
        let(:set_presence) { user.present_for!([training_1, training_2]) }

        it { expect { set_presence }.to change(TrainingPresence, :count).by(2) }
      end

      context 'passed as params' do
        let(:set_presence) { user.present_for!(training_1, training_2) }

        it { expect { set_presence }.to change(TrainingPresence, :count).by(2) }
      end
    end
  end

  describe '#is_present_for?' do
    let(:training) { create :training }

    context 'without any response' do
      it { expect(user.is_present_for?(training)).to be_nil }
    end

    context 'without a nil response' do
      let!(:training_presence) { create :training_presence, training: training, user: user, present: nil }

      it { expect(user.is_present_for?(training)).to be_nil }
    end

    context 'without a true response' do
      let!(:training_presence) { create :training_presence, training: training, user: user, present: true }

      it { expect(user.is_present_for?(training)).to be_truthy }
    end

    context 'without a false response' do
      let!(:training_presence) { create :training_presence, training: training, user: user, present: false }

      it { expect(user.is_present_for?(training)).to be_falsy }
    end
  end

  describe '#is_club_admin?' do
    let(:club) { create :club }

    context 'with other club' do
      it { expect(user.is_admin_of?(club)).to be_falsy }
    end

    context 'with club as admin' do
      before { club.add_admin!(user) }

      it { expect(user.is_admin_of?(club)).to be_truthy }
    end
  end

  describe '#next_week_trainings' do
    let(:training_group_ids) { [group.id] }
    let(:training_date) { 1.week.from_now }
    let(:user_group_ids) { [group.id] }
    let(:group) { create :group, section: section }
    let(:user) { create :user, with_section: section, group_ids: user_group_ids }
    let(:training) { create :training, with_section: section, start_datetime: training_date, group_ids: training_group_ids }

    before { training }

    context 'when user is training group and training date is next week' do
      it { expect(user.next_week_trainings).to include(training) }
    end

    context 'when date is passed' do
      let(:training_date) { 1.day.ago }

      it { expect(user.next_week_trainings).not_to include(training) }
    end

    context 'when date is in 2 weeks' do
      let(:training_date) { 2.weeks.from_now }

      it { expect(user.next_week_trainings).not_to include(training) }
    end

    context 'when user is not in training groups' do
      let(:user_group_ids) { [] }

      it { expect(user.next_week_trainings).not_to include(training) }
    end

    context 'when user is in 2 training groups' do
      let(:group_2) { create :group, section: section }
      let(:user_group_ids) { [group.id, group_2.id] }
      let(:training_group_ids) { [group.id, group_2.id] }

      it { expect(user.next_week_trainings).to include(training) }
      it { expect(user.next_week_trainings.count).to eq 1 }
    end
  end

  describe '#is_available_for?' do
    subject { user.is_available_for?(match) }

    let(:match) { create :match }

    context 'when player has not respond' do
      it { is_expected.to be_falsy }
    end

    context 'when player has responded no' do
      before { MatchAvailability.create! user: user, match: match, available: false }

      it { is_expected.to be_falsy }
    end

    context 'when player has responded yes' do
      before { MatchAvailability.create! user: user, match: match, available: true }

      it { is_expected.to be_truthy }
    end
  end

  describe '.create' do
    describe '#format_phone_number' do
      subject { create(:user, phone_number: phone_number).phone_number }

      context 'with phone number 0123456789' do
        let(:phone_number) { "0123456789" }

        it { is_expected.to eq '01 23 45 67 89' }
      end

      context 'with phone number \'01 23 45 67 89\'' do
        let(:phone_number) { "01 23 45 67 89" }

        it { is_expected.to eq '01 23 45 67 89' }
      end

      context 'with phone number \' 01  2345 67 89 \'' do
        let(:phone_number) { ' 01  2345 67 89 ' }

        it { is_expected.to eq '01 23 45 67 89' }
      end

      context 'with phone number \'+33(0)1 23-45-67\t89\'' do
        let(:phone_number) { '+33(0)1 23-45-67\t89' }

        it { is_expected.to eq '+33(0)1 23-45-67\t89' }
      end
    end
  end

  describe '.active_this_season' do
    subject(:active_users) { User.active_this_season }

    context 'with an active user' do
      before { section.add_player! user }

      it { expect(active_users.count).to eq 1 }

      context 'after 14 months' do
        before { Timecop.travel 14.months.from_now }

        it { expect(active_users.count).to eq 0 }

        context 'with a readded user' do
          before { section.add_player! user }

          it { expect(active_users.count).to eq 1 }

          context 'then deleted' do
            before { section.remove_member! user }

            it { expect(active_users.count).to eq 0 }
          end
        end
      end
    end

    context 'with an user player and coach' do
      before do
        section.add_player! user
        section.add_coach! user
      end

      it { expect(active_users.count).to eq 1 }
    end
  end

  describe '#realised_task!' do
    let(:task) { Faker::Lorem.word }

    it 'create a duty_task' do
      expect { user.realised_task!(task, 1.day.ago) }.to change { user.duty_tasks.reload.count }
    end
  end
end
