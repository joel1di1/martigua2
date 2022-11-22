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

  it { is_expected.to have_and_belong_to_many :sections }
  it { is_expected.to have_and_belong_to_many :groups }
  it { is_expected.to have_many :training_presences }
  it { is_expected.to validate_presence_of :start_datetime }

  describe '#name' do
    context 'with location nil' do
      let(:training) { create(:training, location: nil) }

      it { expect(training.name).to be }
    end
  end

  describe '#nb_presents' do
    context 'with n users present' do
      before { nb_users.times { create(:user).present_for!(training) } }

      it { expect(training.nb_presents).to eq nb_users }
    end
  end

  describe '#nb_not_presents' do
    context 'with n users not presents' do
      before { nb_users.times { create(:user).not_present_for!(training) } }

      it { expect(training.nb_not_presents).to eq nb_users }
    end
  end

  describe '#nb_presence_not_set' do
    before { nb_users.times { create(:user, with_section: section, group_ids: [group.id]) } }

    it { expect(training.nb_presence_not_set).to eq nb_users }
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

      it {
        Sidekiq::Testing.inline! do
          expect do
            described_class.send_presence_mail_for_next_week
          end.to change(ActionMailer::Base.deliveries, :count).by(nb_users)
        end
      }
    end

    context 'with no trainings for users' do
      let(:trainings) { [] }

      it {
        expect do
          described_class.send_presence_mail_for_next_week
        end.not_to change(ActionMailer::Base.deliveries, :count)
      }
    end
  end

  describe '.of_next_week' do
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

    it { expect(described_class.of_next_week(section:, date: now)).to eq trainings[2..4] }
  end

  describe 'users' do
    let(:user) { create(:user, with_section: section, group_ids:) }

    context 'with user not in training group' do
      let(:group_ids) { [] }

      it { expect(training.users).not_to include(user) }
    end

    context 'with user in training group' do
      let(:group_ids) { [group.id] }

      it { expect(training.users).to include(user) }
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
    subject { training.repeat_next_week! }

    its(:start_datetime) { is_expected.to eq(training.start_datetime + 1.week) }
    its(:end_datetime) { is_expected.to eq(training.end_datetime + 1.week) }
    its(:sections) { is_expected.to eq(training.sections) }
    its(:groups) { is_expected.to eq(training.groups) }
    its(:location) { is_expected.to eq(training.location) }
  end

  describe '#repeat_until!' do
    let!(:training) { create(:training, start_datetime: 2.days.from_now) }
    let(:nb_weeks) { rand(2..6) }
    let(:end_date) { nb_weeks.weeks.from_now }

    it { expect { training.repeat_until!(end_date) }.to change(described_class, :count).by(nb_weeks - 1) }
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
        it { expect(training.cancel_reason).to eq reason }

        context 'when uncancelled' do
          before { training.uncancel! }

          it { is_expected.to be_falsy }
          it { expect(training.cancel_reason).to be_nil }
        end
      end
    end
  end

  describe '.send_tig_mail_for_next_training' do
    it 'is not tested'
  end

  describe '#next_duties' do
    let(:present_player1) { create(:user) }
    let(:present_player2) { create(:user) }
    let(:present_player3) { create(:user) }
    let(:present_player4) { create(:user) }
    let(:not_present_player) { create(:user) }
    let(:no_response_player) { create(:user) }
    let(:section) { create(:section) }
    let(:club) { section.club }
    let(:group)    { create(:group, section:) }
    let(:training) { create(:training, with_section: section, group_ids: [group.id]) }

    before do
      group.add_user!(present_player1)
      group.add_user!(present_player2)
      group.add_user!(present_player3)
      group.add_user!(present_player4)
      group.add_user!(not_present_player)

      present_player1.present_for!(training)
      present_player2.present_for!(training)
      present_player3.present_for!(training)
      present_player4.present_for!(training)
      not_present_player.not_present_for!(training)

      create(:duty_task, user: present_player1, weight: 2, realised_at: 1.day.ago, club:)
      create(:duty_task, user: present_player2, weight: 1, realised_at: 6.months.ago, club:)
      create(:duty_task, user: present_player2, weight: 1, realised_at: 6.months.ago, club:)
      create(:duty_task, user: present_player2, weight: 1, realised_at: 6.months.ago, club:)
      create(:duty_task, user: present_player3, weight: 2, realised_at: 2.months.ago, club:)
    end

    it 'select present players order by weight then date of last duties' do
      next_duties = training.next_duties(10)

      expect(next_duties).to include(present_player1)
      expect(next_duties).to include(present_player2)
      expect(next_duties).to include(present_player3)
      expect(next_duties).to include(present_player4)
      expect(next_duties).not_to include(not_present_player)
      expect(next_duties).not_to include(no_response_player)

      expect(next_duties).to match([present_player4, present_player3, present_player1, present_player2])
    end
  end
end
