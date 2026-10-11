# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define :db_object_eq do |x|
  match { |actual| actual == x }
end

RSpec.describe Training do
  let(:training) { create(:training, with_section: section, group_ids: [group.id]) }
  let(:group)    { create(:group, section:) }
  let(:section)  { create(:section) }
  let!(:nb_users) { [1, 2, 3, 4].sample }

  it { is_expected.to have_many :section_trainings }
  it { is_expected.to have_many(:sections).through(:section_trainings) }
  it { is_expected.to have_many :group_trainings }
  it { is_expected.to have_many(:groups).through(:group_trainings) }
  it { is_expected.to have_many :training_presences }
  it { is_expected.to validate_presence_of :start_datetime }

  describe '#nb_presents' do
    context 'with n users present' do
      before { nb_users.times { create(:user, with_section: section, group_ids: [group.id]).present_for!(training) } }

      it 'training.nb_presents is expected to eq nb_users' do
        expect(training.nb_presents).to eq nb_users
      end
    end

    context 'with a user present who is not in the training groups' do
      before { create(:user).present_for!(training) }

      it { expect(training.nb_presents).to eq 0 }
      it { expect(training.presents).to be_empty }
    end
  end

  describe '#nb_not_presents' do
    context 'with n users not presents' do
      before { nb_users.times { create(:user, with_section: section, group_ids: [group.id]).not_present_for!(training) } }

      it 'training.nb_not_presents is expected to eq nb_users' do
        expect(training.nb_not_presents).to eq nb_users
      end
    end

    context 'with a user not present who is not in the training groups' do
      before { create(:user).not_present_for!(training) }

      it { expect(training.nb_not_presents).to eq 0 }
      it { expect(training.not_presents).to be_empty }
    end
  end

  describe '#nb_presence_not_set' do
    before { nb_users.times { create(:user, with_section: section, group_ids: [group.id]) } }

    it 'training.nb_presence_not_set is expected to eq nb_users' do
      expect(training.nb_presence_not_set).to eq nb_users
    end
  end

  describe 'presences validated by the coach' do
    let(:cheater) { create(:user, with_section: section, group_ids: [group.id]) }
    let(:silent) { create(:user, with_section: section, group_ids: [group.id]) }
    let(:honest) { create(:user, with_section: section, group_ids: [group.id]) }
    let(:excused) { create(:user, with_section: section, group_ids: [group.id]) }

    before do
      cheater.present_for!(training)
      cheater.confirm_no_presence!(training)
      silent.confirm_presence!(training)
      honest.present_for!(training)
      excused.not_present_for!(training)
      excused.confirm_presence!(training)
    end

    it 'training.presents is expected to contain exactly silent, honest, excused' do
      expect(training.presents).to contain_exactly(silent, honest, excused)
    end

    it 'training.not_presents is expected to contain exactly cheater' do
      expect(training.not_presents).to contain_exactly(cheater)
    end

    it { expect(training.presence_not_set).to be_empty }
    it { expect(training.nb_presents).to eq 3 }
    it { expect(training.nb_not_presents).to eq 1 }
  end

  describe '.send_presence_mail_for_next_week' do
    let(:users) { (1..nb_users).map { create(:user, with_section: section, group_ids: [group.id]) } }

    before do
      User.delete_all
      allow(User).to receive(:active_this_season).and_return(users)
      users.each { |user| allow(user).to receive(:next_week_trainings).and_return(trainings) }
    end

    context 'with trainings for users' do
      let(:trainings) { [training] }

      it 'sends one mail per user' do
        run_jobs_inline do
          expect do
            Training.send_presence_mail_for_next_week
          end.to change(ActionMailer::Base.deliveries, :count).by(nb_users)
        end
      end
    end

    context 'with no trainings for users' do
      let(:trainings) { [] }

      it 'sends no mail' do
        expect do
          Training.send_presence_mail_for_next_week
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
  end

  describe '.with_start_on' do
    let(:now) { DateTime.new(2014, 8, 19, 13, 12, 55, '1') } # tuesday
    let(:dates) do
      [
        now - 1.week,
        now + 5.days, # sunday 24
        now + 6.days, # monday 25
        now + 7.days, # tuesday 26
        now + 12.days, # sunday 31
        now + 2.weeks
      ]
    end

    let!(:trainings) { dates.map { |date| create(:training, with_section: section, start_datetime: date) } }

    let(:days) { [now + 6.days, now + 7.days, now + 12.days] }

    it 'Training.with_start_on(days) is expected to eq trainings[2..4]' do
      expect(Training.with_start_on(days)).to eq trainings[2..4]
    end
  end

  describe 'users' do
    let(:user) { create(:user, with_section: section, group_ids:) }

    context 'with user not in training group' do
      let(:group_ids) { [] }

      it 'training.users is expected not to include user' do
        expect(training.users).not_to include(user)
      end
    end

    context 'with user in training group' do
      let(:group_ids) { [group.id] }

      it 'training.users is expected to include user' do
        expect(training.users).to include(user)
      end
    end
  end

  describe '#group_names' do
    let(:group1)    { create(:group, section:, name: 'TEST') }
    let(:group2)    { create(:group, section:, name: 'AA TEST') }
    let(:group_ids) { [group1.id, group2.id] }
    let(:training) { create(:training, with_section: section, group_ids:) }

    it { expect(training.group_names).to eq 'AA TEST, TEST' }
  end

  describe '#repeat_next_week!' do
    subject(:next_week_training) { training.repeat_next_week! }

    it('start_datetime is one week later') { expect(next_week_training.start_datetime).to eq(training.start_datetime + 1.week) }
    it('end_datetime is one week later') { expect(next_week_training.end_datetime).to eq(training.end_datetime + 1.week) }
    it('sections are copied') { expect(next_week_training.sections).to eq(training.sections) }
    it('groups are copied') { expect(next_week_training.groups).to eq(training.groups) }
    it('location is copied') { expect(next_week_training.location).to eq(training.location) }
    it('max_capacity is copied') { expect(next_week_training.max_capacity).to eq(training.max_capacity) }
  end

  describe '#repeat_until!' do
    let!(:training) { create(:training, start_datetime: 2.days.from_now) }
    let(:nb_weeks) { rand(2..6) }
    let(:end_date) { nb_weeks.weeks.from_now }

    it 'creates nb_weeks - 1 trainings' do
      expect { training.repeat_until!(end_date) }.to change(Training, :count).by(nb_weeks - 1)
    end
  end

  describe 'cancel uncancel' do
    let(:reason) { "For this reason #{Faker::Lorem.sentence}" }

    describe '#cancelled?' do
      subject { training.cancelled? }

      context 'when not cancelled' do
        it { is_expected.to be_falsy }
      end

      context 'when cancelled' do
        before { training.cancel!(reason:) }

        it { is_expected.to be_truthy }

        it 'training.cancel_reason is expected to eq reason' do
          expect(training.cancel_reason).to eq reason
        end

        context 'when uncancelled' do
          before { training.uncancel! }

          it { is_expected.to be_falsy }
          it { expect(training.cancel_reason).to be_nil }
        end
      end
    end
  end

  describe '#max_capacity_reached?' do
    let(:training) { create(:training, with_section: section, group_ids: [group.id], max_capacity: 2) }

    context 'with max capacity nil' do
      before { training.update(max_capacity: nil) }

      it { expect(training).not_to be_max_capacity_reached }
    end

    context 'with max capacity reached' do
      before { 2.times { create(:user).present_for!(training) } }

      it { expect(training).to be_max_capacity_reached }
    end

    context 'with max capacity not reached' do
      before { create(:user).present_for!(training) }

      it { expect(training).not_to be_max_capacity_reached }
    end
  end

  describe '#calculated_start_datetime' do
    it 'training.calculated_start_datetime is expected to eq training.start_datetime' do
      expect(training.calculated_start_datetime).to eq training.start_datetime
    end
  end
end
