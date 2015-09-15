require 'rails_helper'

RSpec.describe Match, :type => :model do
  it { should belong_to :local_team }
  it { should belong_to :visitor_team }
  it { should belong_to :day }

  it { should have_many :selections }

  describe "#date" do
    let(:day) { nil }

    let(:match) { create :match, start_datetime: start_datetime, day: day }

    context "with specified start_datetime" do
      let(:start_datetime) { 1.week.from_now }

      it { expect(match.date).to eq start_datetime.to_s(:short) }
    end

    context "with no start_datetime specified" do
      let(:start_datetime) { nil }

      context "with day specified" do
        let(:day) { create :day }

        it { expect(match.date).to eq day.name }
      end
    end
  end
end
