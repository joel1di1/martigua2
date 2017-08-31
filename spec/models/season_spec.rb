require 'rails_helper'

RSpec.describe Season, :type => :model do
  it { should have_many :participations }
  it { should have_many :calendars }
  it { should have_many :championships }

  it { should validate_presence_of :name }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }

  let(:season) { create :season }

  describe '.current' do
    before { Season.destroy_all }

    context 'with only one season' do
      let!(:only_season) { create :season, start_date: Date.today - 1.month }
      subject { Season.current }
      it { should eq only_season }
    end

    context 'with one old season' do
      let(:today) { Date.today }
      let!(:first_season) { create :season, start_date: Date.new(2001, 9, 1) }

      it { expect(Season.current.start_date).to be < today }
      it { expect(Season.current.end_date).to be > today }
    end

    context 'with no season' do
      subject { Season.current }
      it { should_not be_nil }
    end
  end

  describe '#to_s' do
    it { expect(season.to_s).to eq "#{season.start_date.year}-#{season.end_date.year}" }
  end

  describe '#previous' do
    subject { Season.current.previous }
    it { expect(subject.start_date).to eq (Season.current.start_date - 1.year) }
  end
end
