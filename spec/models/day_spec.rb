require 'rails_helper'

RSpec.describe Day, :type => :model do
  it { should belong_to :calendar }
  it { should have_many :matches }

  it { should validate_presence_of :name }

  describe 'create with period_start_date should set defaut period_end_date' do
    subject { day.period_end_date }

    let(:day) { build :day, period_start_date: start_date, period_end_date: end_date }

    before { day.save! }

    context 'with start_date random' do
      let(:start_date) { Date.today + 3 }

      context 'and end_date not set' do
        let(:end_date) { nil }

        it { is_expected.to eq (start_date + 1) }
      end

      context 'and end_date set' do
        let(:end_date) { Date.parse("2010-09-12") }

        it { is_expected.to eq (end_date) }
      end
    end

    context 'with start_date nil' do
      let(:start_date) { nil }

      context 'and end_date not nil' do
        let(:end_date) { Date.parse("2010-09-12") }

        it { is_expected.to eq end_date }
      end

      context 'and end_date nil' do
        let(:end_date) { nil }

        it { is_expected.to eq nil }
      end
    end
  end

  describe 'update period_start_date should set defaut period_end_date' do
    subject { day.period_end_date }

    let(:new_end_date) { Date.parse("2010-09-12") }
    let(:old_end_date) { Date.parse("2003-03-06") }
    let(:day) { create :day, period_end_date: old_end_date }

    before { day.update_attributes(params) }

    context 'with start_date random' do
      let(:new_start_date) { Date.today + 3 }

      context 'and end_date not set' do
        let(:params) { { period_start_date: new_start_date } }

        it { is_expected.to eq new_start_date + 1 }
      end

      context 'and end_date set' do
        let(:params) { { period_start_date: new_start_date, period_end_date: new_end_date } }

        it { is_expected.to eq new_end_date }
      end
    end

    context 'with start_date not set' do
      context 'and end_date not set' do
        let(:params) { {} }

        it { is_expected.to eq old_end_date }
      end

      context 'and end_date set' do
        let(:params) { { period_end_date: new_end_date } }

        it { is_expected.to eq new_end_date }
      end
    end
  end
end
