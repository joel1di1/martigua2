require 'rails_helper'

RSpec.describe Season, :type => :model do
  it { should validate_presence_of :name }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }

  describe '.current' do
    before { Season.destroy_all }

    context 'with only one season' do
      let!(:only_season) { create :season }
      subject { Season.current }
      it { should eq only_season }
    end

    context 'with two seasons' do
      let!(:first_season) { create :season }
      let!(:second_season) { create :season }
      subject { Season.current }
      it { should eq Season.last }
    end

    context 'with no season' do
      subject { Season.current }
      it { should_not be_nil }
    end
  end
end
