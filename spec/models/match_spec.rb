require 'rails_helper'

RSpec.describe Match, :type => :model do
  it { should belong_to :local_team }
  it { should belong_to :visitor_team }
  it { should belong_to :day }

  describe "#date" do
    let(:prevision_period_start) { 1.week.from_now }
    let(:prevision_period_end) { 1.week.from_now + 2.days}
    let(:day) { nil }

    let(:match) { create :match, start_datetime: start_datetime, 
                                 prevision_period_start: prevision_period_start,
                                 prevision_period_end: prevision_period_end,
                                 day: day }

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

      context "with no prevision period specified" do
        let(:prevision_period_start) { nil }
        let(:prevision_period_end) { nil }

        it { expect(match.date).to eq "" }
      end
 
      context "with prevision period specified" do
        let(:prevision_period_start) { 1.week.from_now }
        let(:prevision_period_end) { 1.week.from_now + 2.days }

        it { expect(match.date).to eq "(#{prevision_period_start.to_date.to_s(:short)} - #{prevision_period_end.to_date.to_s(:short)})" }
      end
    end
  end
end
