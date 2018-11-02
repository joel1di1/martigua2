require 'rails_helper'

RSpec::Matchers.define :db_object_eq do |x|
  match { |actual| actual == x }
end

RSpec.describe Training, :type => :model do
  let(:training) { create :training, with_section: section, group_ids: [group.id] }
  let(:group)    { create :group, section: section }
  let(:section)  { create :section }
  let!(:nb_users) { [1, 2, 3, 4].sample }
  it { should have_and_belong_to_many :sections }
  it { should have_and_belong_to_many :groups }
  it { should have_many :training_presences }
  it { should validate_presence_of :start_datetime }

  describe '#nb_presents' do
    context 'with n users present' do
      before { nb_users.times { (create :user).present_for!(training) } }

      it { expect(training.nb_presents).to eq nb_users }
    end
  end

  describe '#nb_not_presents' do
    context 'with n users not presents' do
      before { nb_users.times { (create :user).not_present_for!(training) } }

      it { expect(training.nb_not_presents).to eq nb_users }
    end
  end

  describe '#nb_presence_not_set' do
    before { nb_users.times { create :user, with_section: section, group_ids: [group.id] } }

    it { expect(training.nb_presence_not_set).to eq nb_users }
  end

  describe '.send_presence_mail_for_next_week' do
    let(:users) { (1..nb_users).map { create :user, with_section: section, group_ids: [group.id] } }

    before { User.delete_all }
    before { allow(User).to receive(:active_this_season).and_return(users) }
    before { users.each { |user| expect(user).to receive(:next_week_trainings).and_return(trainings) } }

    context 'with trainings for users' do
      let(:trainings) { [training] }
      it { expect { Training.send_presence_mail_for_next_week }.to change { ActionMailer::Base.deliveries.count }.by(nb_users) }
    end
    context 'with no trainings for users' do
      let(:trainings) { [] }
      it { expect { Training.send_presence_mail_for_next_week }.to change { ActionMailer::Base.deliveries.count }.by(0) }
    end
  end

  describe '.of_next_week' do
    let(:now) { DateTime.new(2014, 8, 19, 13, 12, 55, '1') } # tuesday
    let(:dates) {
      [
        now - 1.week,
        now + 5.days, # sunday 24
        now + 6.days, # monday 25
        now + 7.days, # tuesday 26
        now + 12.days, # sunday 31
        now + 2.weeks
      ]
    }

    let!(:trainings) { dates.map { |date| create :training, with_section: section, start_datetime: date } }

    it { expect(Training.of_next_week(section, now)).to eq trainings[2..4] }
  end

  describe 'users' do
    let(:user) { create :user, with_section: section, group_ids: group_ids }

    context 'with user not in training group' do
      let(:group_ids) { [] }
      it { expect(training.users).to_not include(user) }
    end

    context 'with user in training group' do
      let(:group_ids) { [group.id] }
      it { expect(training.users).to include(user) }
    end
  end

  describe '#group_names' do
    let(:group_1)    { create :group, section: section, name: 'TEST' }
    let(:group_2)    { create :group, section: section, name: 'AA TEST' }
    let(:group_ids) { [group_1.id, group_2.id] }
    let(:training) { create :training, with_section: section, group_ids: group_ids }

    it { expect(training.group_names).to eq "AA TEST, TEST" }
  end

  describe '#repeat_next_week!' do
    subject { training.repeat_next_week! }
    its(:start_datetime) { is_expected.to eq(training.start_datetime + 1.week) }
    its(:end_datetime) { is_expected.to eq(training.end_datetime + 1.week) }
    its(:sections) { is_expected.to eq(training.sections) }
    its(:groups) { is_expected.to eq(training.groups) }
    its(:location) { is_expected.to eq(training.location) }
  end

  describe '#repeat_until!' do
    let!(:training) { create :training, start_datetime: 2.days.from_now }
    let(:nb_weeks) { rand(2..6) }
    let(:end_date) { nb_weeks.weeks.from_now }
    it { expect { training.repeat_until!(end_date) }.to change { Training.count }.by(nb_weeks - 1) }
  end

  describe 'cancel uncancel' do
    let(:reason) { "For this reason " + Faker::Lorem.sentence }
    describe '#cancelled?' do
      subject { training.cancelled? }

      context 'when not cancelled' do
        it { is_expected.to be_falsy }
      end
      context 'when cancelled' do
        before { training.cancel!(reason) }
        it { is_expected.to be_truthy }
        it { expect(training.cancel_reason).to eq reason }
        context 'when uncancelled' do
          before { training.uncancel! }
          it { is_expected.to be_falsy }
          it { expect(training.cancel_reason).to be_nil }
        end
      end
    end
  end
end
