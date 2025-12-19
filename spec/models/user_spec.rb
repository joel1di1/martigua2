# frozen_string_literal: true

describe User do
  let(:section) { create(:section) }
  let(:user) { create(:user) }

  it { is_expected.to validate_presence_of :email }

  describe 'email validation' do
    it 'accepts valid email addresses' do
      valid_emails = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
      valid_emails.each do |valid_email|
        user.email = valid_email
        expect(user).to be_valid, "#{valid_email.inspect} should be valid"
      end
    end

    it 'rejects invalid email addresses' do
      invalid_emails = ['user_at_foo.org', 'foo bar@example.com', '@example.com']
      invalid_emails.each do |invalid_email|
        user.email = invalid_email
        expect(user).not_to be_valid, "#{invalid_email.inspect} should be invalid"
      end
    end

    it 'rejects blank email' do
      user.email = ''
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('doit être rempli(e)')
    end
  end

  it { is_expected.to have_db_column :first_name }
  it { is_expected.to have_db_column :last_name }
  it { is_expected.to have_db_column :nickname }
  it { is_expected.to have_db_column :phone_number }
  it { is_expected.to have_many :club_admin_roles }
  it { is_expected.to have_many :participations }
  it { is_expected.to have_many :sections }
  it { is_expected.to have_many :training_presences }
  it { is_expected.to have_many :duty_tasks }
  it { is_expected.to have_many :burns }
  it { is_expected.to have_many :group_memberships }
  it { is_expected.to have_many :groups }

  describe 'authentication token should be generated' do
    subject { create(:user, authentication_token: nil) }

    its(:authentication_token) { is_expected.not_to be_nil }
    its(:id) { is_expected.not_to be_nil }
  end

  describe '#short_name' do
    it 'returns nickname or full name' do
      user = create(:user, nickname: nil)
      expect(user.short_name).to eq "#{user.first_name.capitalize} #{user.last_name.capitalize}"
      nickname = Faker::Name.first_name
      user.update!(nickname:)
      expect(user.short_name).to eq nickname
    end
  end

  describe '#has_only_one_section?' do
    subject { user.has_only_one_section? }

    context 'user with no section' do
      it { is_expected.to be false }
    end

    context 'user with two sections' do
      let!(:participation1) { create(:participation, user:) }
      let!(:participation2) { create(:participation, user:) }

      it { is_expected.to be false }
    end

    context 'user with one section' do
      let!(:participation1) { create(:participation, user:) }

      it { is_expected.to be true }
    end

    context 'user with two participations on one section' do
      let!(:participation1) { create(:participation, user:, section:, role: Participation::PLAYER) }
      let!(:participation2) { create(:participation, user:, section:, role: Participation::COACH) }

      it { is_expected.to be true }
    end
  end

  describe '#coach_of?' do
    subject { user.coach_of?(section) }

    context 'with a user not in the section' do
      it { is_expected.to be false }
    end

    context 'with a player of the section' do
      before { section.add_player!(user) }

      it { is_expected.to be false }
    end

    context 'with a coach of the section' do
      before { section.add_coach!(user) }

      it { is_expected.to be true }
    end

    context 'with a last year coach of the section' do
      let(:previous_season) { create(:season, start_date: 2.years.ago) }

      before { section.add_coach!(user, season: previous_season) }

      # With automatic coach renewal, coaches are automatically renewed each season
      # So a coach from 2 years ago will be renewed to last year, then to this year
      it { is_expected.to be_truthy }
    end
  end

  describe '#player_of?' do
    subject { user.player_of?(section) }

    context 'with a player not in the section' do
      it { is_expected.to be false }
    end

    context 'with a player of the section' do
      before { section.add_player!(user) }

      it { is_expected.to be true }
    end

    context 'with a coach of the section' do
      before { section.add_coach!(user) }

      it { is_expected.to be false }
    end

    context 'with a last year player of the section' do
      let(:previous_season) { create(:season, start_date: 2.years.ago) }

      before { section.add_player!(user, season: previous_season) }

      it { is_expected.to be_falsy }
    end
  end

  describe '#display_participations' do
    let(:display) { user.display_participations }

    context 'with one participation' do
      let!(:participation) { create(:participation, user:) }

      it { expect(display).to include(participation.section.club.name) }
      it { expect(display).to include(participation.section.name) }
      it { expect(display).to include(participation.role) }
      it { expect(display).to include(participation.season.to_s) }
    end
  end

  describe '#present_for!' do
    context 'with one training' do
      subject(:set_presence) { user.present_for!(training) }

      let(:training) { create(:training, with_section: section, with_group: section.group_every_players) }

      it { expect { set_presence }.to change(TrainingPresence, :count).by(1) }

      describe 'user availability' do
        before { set_presence }

        it { expect(user).to be_present_for(training) }
      end

      describe 'double presence set' do
        it { expect { 2.times { user.present_for!(training) } }.to change(TrainingPresence, :count).by(1) }
      end

      context 'when training reached max players' do
        before do
          training.update!(max_capacity: 1)
          other_user = create(:user, with_section: section)
          create(:training_presence, training:, user: other_user, is_present: true)
        end

        it 'does not create a presence' do
          expect { set_presence }.not_to change(TrainingPresence, :count)
        end
      end
    end

    context 'with two trainings' do
      let(:training1) { create(:training) }
      let(:training2) { create(:training) }

      context 'passed as array' do
        let(:set_presence) { user.present_for!([training1, training2]) }

        it { expect { set_presence }.to change(TrainingPresence, :count).by(2) }
      end

      context 'passed as params' do
        let(:set_presence) { user.present_for!(training1, training2) }

        it { expect { set_presence }.to change(TrainingPresence, :count).by(2) }
      end
    end
  end

  describe '#present_for?' do
    let(:training) { create(:training) }

    context 'without any response' do
      it { expect(user.present_for?(training)).to be_nil }
    end

    context 'without a nil response' do
      let!(:training_presence) { create(:training_presence, training:, user:, is_present: nil) }

      it { expect(user.present_for?(training)).to be_nil }
    end

    context 'without a true response' do
      let!(:training_presence) { create(:training_presence, training:, user:, is_present: true) }

      it { expect(user).to be_present_for(training) }
    end

    context 'without a false response' do
      let!(:training_presence) { create(:training_presence, training:, user:, is_present: false) }

      it { expect(user).not_to be_present_for(training) }
    end
  end

  describe '#admin_of?' do
    let(:club) { create(:club) }

    context 'with other club' do
      it { expect(user).not_to be_admin_of(club) }
    end

    context 'with club nil' do
      it { expect(user).not_to be_admin_of(nil) }
    end

    context 'with club as admin' do
      before { club.add_admin!(user) }

      it { expect(user).to be_admin_of(club) }
    end
  end

  describe '#next_week_trainings' do
    let(:training_group_ids) { [group.id] }
    let(:training_date) { Time.zone.now.next_week + 2.days }
    let(:user_group_ids) { [group.id] }
    let(:group) { create(:group, section:) }
    let(:user) { create(:user, with_section: section, group_ids: user_group_ids) }
    let(:training) do
      create(:training, with_section: section, start_datetime: training_date, group_ids: training_group_ids)
    end

    before { training }

    context 'when user is training group and training date is next week' do
      it { expect(user.next_week_trainings).to include(training) }
    end

    context 'when date is passed' do
      let(:training_date) { 1.day.ago }

      it { expect(user.next_week_trainings).not_to include(training) }
    end

    context 'when date is in 2 weeks' do
      let(:training_date) { 16.days.from_now }

      it { expect(user.next_week_trainings).not_to include(training) }
    end

    context 'when user is not in training groups' do
      let(:user_group_ids) { [] }

      it { expect(user.next_week_trainings).not_to include(training) }
    end

    context 'when user is in 2 training groups' do
      let(:group2) { create(:group, section:) }
      let(:user_group_ids) { [group.id, group2.id] }
      let(:training_group_ids) { [group.id, group2.id] }

      it { expect(user.next_week_trainings).to include(training) }
      it { expect(user.next_week_trainings.count).to eq 1 }

      context 'when user is away' do
        before { create(:absence, user:, start_at: training_date - 2.weeks, end_at: training_date + 2.weeks) }

        it { expect(user.reload.next_week_trainings).not_to include(training) }
      end
    end
  end

  describe '#is_available_for?' do
    subject { user.is_available_for?(match) }

    let(:match) { create(:match) }

    context 'when player has not respond' do
      it { is_expected.to be_falsy }
    end

    context 'when player has responded no' do
      before { MatchAvailability.create! user:, match:, available: false }

      it { is_expected.to be_falsy }
    end

    context 'when player has responded yes' do
      before { MatchAvailability.create! user:, match:, available: true }

      it { is_expected.to be_truthy }
    end
  end

  describe '.active_this_season' do
    subject(:active_users) { User.active_this_season }

    context 'with an active user' do
      before { section.add_player! user }

      context 'when user just has been added' do
        it { expect(active_users.count).to eq 1 }
      end

      context 'when 14 months has passed' do
        before { Timecop.travel 14.months.from_now }
        after { Timecop.return }

        it 'expects users to reset activation' do
          expect(active_users.count).to eq 0

          section.add_player! user
          expect(active_users.count).to eq 1

          section.remove_member! user
          expect(active_users.count).to eq 0
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
    let(:task) { DutyTask::TASKS.keys.sample }

    it 'create a duty_task' do
      expect { user.realised_task!(task, 1.day.ago, section.club) }.to(change { user.duty_tasks.reload.count })
    end
  end

  describe 'validates presence on trainings' do
    subject(:was_present) { user.was_present?(training) }

    let(:user) { create(:user, with_section: section) }
    let(:training) { create(:training, with_section: section) }

    context 'with availability not set' do
      it { expect(was_present).to be_falsy }
    end

    context 'with availability set to false' do
      before { user.not_present_for!(training) }

      context 'with no validation by coach' do
        it { expect(was_present).to be_falsy }
      end

      context 'with presence validation by coach' do
        before { user.confirm_presence!(training) }

        it { expect(was_present).to be_truthy }
      end
    end
  end

  describe '#confirm_presence!' do
    let(:user) { create(:user, with_section: section) }
    let(:training) { create(:training, with_section: section) }

    context 'with availability not set' do
      it 'create presence and presence matchs confirmation' do
        expect(user).not_to be_was_present(training)
        expect { user.confirm_presence!(training) }.to change(user.training_presences, :count).by(1)
        expect(user).to be_was_present(training)
        user.confirm_no_presence!(training)
        expect(user).not_to be_was_present(training)
      end
    end

    context 'with availability set to false' do
      before { user.not_present_for!(training) }

      it 'presence matchs confirmation' do
        expect(user).not_to be_was_present(training)
        user.confirm_presence!(training)
        expect(user).to be_was_present(training)
        user.confirm_no_presence!(training)
        expect(user).not_to be_was_present(training)
      end
    end

    context 'with availability set to true' do
      before { user.present_for!(training) }

      it 'presence matchs confirmation' do
        expect(user).to be_was_present(training)
        user.confirm_no_presence!(training)
        expect(user).not_to be_was_present(training)
        user.confirm_presence!(training)
        expect(user).to be_was_present(training)
      end
    end
  end

  describe '#not_available_for!' do
    let(:user) { create(:user, with_section: section) }
    let(:match) { create(:match) }
    let(:other_match) { create(:match) }

    context 'with availability not set' do
      it 'create match_availability' do
        expect(user.is_available_for?(match)).to be_nil
        expect { user.not_available_for!(match) }.to change(user.match_availabilities, :count).by(1)
        expect(user).not_to be_is_available_for(match)
      end
    end

    context 'with availability set to true' do
      before { create(:match_availability, user:, match:, available: true) }

      it 'create match_availability' do
        expect(user).to be_is_available_for(match)
        user.not_available_for!(match)
        expect(user.reload).not_to be_is_available_for(match)
      end
    end

    context 'with array of matchs' do
      it 'update match_availabilities' do
        expect(user.reload.is_available_for?(match)).to be_nil
        expect(user.reload.is_available_for?(other_match)).to be_nil
        user.not_available_for!([match, other_match])
        expect(user.reload).not_to be_is_available_for(match)
        expect(user.reload).not_to be_is_available_for(other_match)
      end
    end
  end
end
