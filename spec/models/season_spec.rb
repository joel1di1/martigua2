require 'rails_helper'

RSpec.describe Season, :type => :model do
  it { should have_many :participations }
  it { should have_many :days }

  it { should validate_presence_of :name }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }

  let(:season) { create :season }

  describe 'after create' do
    it "triggers create_default_days! on save" do
      season = build :season
      expect(season).to receive(:create_default_days!)
      season.save!
    end
  end

  describe '#create_default_days!' do
    let(:start_date) { Date.new(2015, 9, 15) }
    let(:end_date) { Date.new(2015, 10, 1) }
    let(:season) { build :season, start_date: start_date, end_date: end_date }

    let(:default_days) { season.create_default_days! }

    it { expect(default_days).not_to be_empty }
    it { expect(default_days.size).to eq 2 }

    it { expect(default_days.first.period_start_date).to eq Date.new(2015,9,19)}
    it { expect(default_days.first.period_end_date).to eq Date.new(2015,9,20)}

    it { expect(default_days.second.period_start_date).to eq Date.new(2015,9,26)}
    it { expect(default_days.second.period_end_date).to eq Date.new(2015,9,27)}
  end

  describe '.current' do
    before { Season.destroy_all }

    context 'with only one season' do
      let!(:only_season) { create :season, start_date: Date.today - 1.month }
      subject { Season.current }
      it { should eq only_season }
    end

    context 'with one old season' do
      let(:d) { Date.new(2015, 9, 22) }
      let!(:first_season) { create :season, start_date: Date.new(2001, 9, 1) }
      
      it { expect(Season.current.start_date).to be < d }
      it { expect(Season.current.end_date).to be > d }
    end

    context 'with no season' do
      subject { Season.current }
      it { should_not be_nil }
    end
  end

  describe '#to_s' do 
    it { expect(season.to_s).to eq "#{season.start_date.year}-#{season.end_date.year}" }
  end
end
