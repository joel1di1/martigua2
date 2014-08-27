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

  let(:section) { create :section }
  let(:training) { create :training, with_section: section }

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
    before { nb_users.times{ create :user, with_section: section } }

    it { expect(training.nb_presence_not_set).to eq nb_users }
  end

  describe '.send_presence_mail_for_next_week' do
    context 'with n users and 3 coachs' do
      before { nb_users.times{ create :user, with_section: section } }
      before { 4.times{ create :user } }
      before { 3.times{ create :user, with_section_as_coach: section } }

      context 'with no training next week' do
        before { allow(Training).to receive(:of_next_week) {[]} }

        it { expect{Training.send_presence_mail_for_next_week}.to change{ActionMailer::Base.deliveries.count}.by(0) }
      end

      context 'with some trainings next week' do
        let(:training_of_other_section) { create :training }
        before { allow(Training).to receive(:of_next_week).and_return([]) }
        before { allow(Training).to receive(:of_next_week).with(db_object_eq(section)).and_return([training]) }

        it { expect{Training.send_presence_mail_for_next_week}.to change{ActionMailer::Base.deliveries.count}.by(nb_users) }
      end
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
end
