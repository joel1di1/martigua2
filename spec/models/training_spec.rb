require 'rails_helper'

RSpec.describe Training, :type => :model do
  it { should validate_presence_of :start_datetime }
  it { should have_and_belong_to_many :sections }
  it { should have_many :training_presences }

  let(:nb_users) { [1,2,3,4,10].sample }
  describe '#nb_presents' do
    let(:training) { create :training }

    context 'with n users present' do
      before { nb_users.times{ (create :user).present_for!(training) } }

      it { expect(training.nb_presents).to eq nb_users }
    end
  end

  describe '#nb_not_presents' do
    let(:training) { create :training }

    context 'with n users not presents' do
      before { nb_users.times{ (create :user).not_present_for!(training) } }

      it { expect(training.nb_not_presents).to eq nb_users }
    end
  end

  describe '#nb_presence_not_set' do
    let(:section) { create :section }
    let(:training) { create :training, with_section: section }

    before { nb_users.times{ create :user, with_section: section } }

    it { expect(training.nb_presence_not_set).to eq nb_users }
  end
end
