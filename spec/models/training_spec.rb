require 'rails_helper'

RSpec::Matchers.define :db_object_eq do |x|
  match { |actual| actual == x }
end

RSpec.describe Training, :type => :model do
  it { should have_and_belong_to_many :sections }
  it { should have_and_belong_to_many :groups }
  it { should have_many :training_presences }
  it { should validate_presence_of :start_datetime }

  let!(:nb_users) { [1,2,3,4,10].sample }

  let(:section)  { create :section }
  let(:group)    { create :group, section: section }
  let(:training) { create :training, with_section: section, group_ids: [group.id] }

  describe '#nb_presents' do
    context 'with n users present' do
      before { nb_users.times{ (create :user).present_for!(training) } }

      it { expect(training.nb_presents).to eq nb_users }
    end
  end

  describe '#nb_not_presents' do
    context 'with n users not presents' do
      before { nb_users.times{ (create :user).not_present_for!(training) } }

      it { expect(training.nb_not_presents).to eq nb_users }
    end
  end

  describe '#nb_presence_not_set' do
    before { nb_users.times{ create :user, with_section: section, group_ids: [group.id] } }

    it { expect(training.nb_presence_not_set).to eq nb_users }
  end

  describe '.send_presence_mail_for_next_week' do
    let(:users) { (1..nb_users).map{ create :user, with_section: section, group_ids: [group.id] } }
    let(:trainings) { [training] }

    before { User.delete_all }
    before { allow(User).to receive(:all).and_return(users) }
    before { users.each{|user| expect(user).to receive(:next_week_trainings).and_return(trainings)} }

    context 'with trainings for users' do
      it { expect{Training.send_presence_mail_for_next_week}.to change{ActionMailer::Base.deliveries.count}.by(nb_users) }
    end
    context 'with no trainings for users' do
      let(:trainings) { [] }
      it { expect{Training.send_presence_mail_for_next_week}.to change{ActionMailer::Base.deliveries.count}.by(0) }
    end
  end

  describe '.of_next_week' do 
    let(:now) { DateTime.new(2014, 8, 19, 13, 12, 55, '1') } # tuesday
    let(:dates) {[now - 1.week, 
                  now + 5.days, # sunday 24
                  now + 6.days, # monday 25
                  now + 7.days, # tuesday 26
                  now + 12.days,# sunday 31
                  now + 2.weeks]}

    let!(:trainings) { dates.map{|date| create :training, with_section: section, start_datetime: date } }

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
end
