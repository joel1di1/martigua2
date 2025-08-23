# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Season do
  let(:season) { create(:season) }

  it { is_expected.to have_many :participations }
  it { is_expected.to have_many :calendars }
  it { is_expected.to have_many :championships }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :start_date }
  it { is_expected.to validate_presence_of :end_date }

  describe '.current' do
    before { described_class.destroy_all }

    context 'with only one season' do
      subject { described_class.current }

      let!(:only_season) { create(:season, start_date: Time.zone.today - 1.month) }

      it { is_expected.to eq only_season }
    end

    context 'with one old season' do
      let(:today) { Time.zone.today }
      let!(:first_season) { create(:season, start_date: Date.new(2001, 9, 1)) }

      it { expect(described_class.current.start_date).to be < today }
      it { expect(described_class.current.end_date).to be >= today }
    end

    context 'with no season' do
      subject { described_class.current }

      it { is_expected.not_to be_nil }
    end
  end

  describe '#to_s' do
    it { expect(season.to_s).to eq "#{season.start_date.year}-#{season.end_date.year}" }
  end

  describe '#previous' do
    subject { described_class.current.previous }

    it { expect(subject.start_date).to eq(described_class.current.start_date - 1.year) }

    context 'with gaps in IDs' do
      before do
        described_class.destroy_all
        middle_season = create(:season, start_date: Date.new(2021, 9, 1), end_date: Date.new(2022, 8, 31))
        middle_season.destroy
      end

      let!(:first_season) { create(:season, start_date: Date.new(2020, 9, 1), end_date: Date.new(2021, 8, 31)) }
      let!(:third_season) { create(:season, start_date: Date.new(2022, 9, 1), end_date: Date.new(2023, 8, 31)) }

      # Create a season with ID gap by deleting the middle one

      it 'finds the previous season despite ID gaps' do
        expect(third_season.previous).to eq(first_season)
      end

      it 'returns nil when there is no previous season' do
        expect(first_season.previous).to be_nil
      end
    end
  end
end
