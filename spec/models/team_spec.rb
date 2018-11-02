require 'rails_helper'

RSpec.describe Team, :type => :model do
  it { should validate_presence_of :club }
  it { should validate_presence_of :name }
  it { should have_many :enrolled_team_championships}
  it { should have_many :championships}

  describe ".team_with_match_on" do
    subject { Team.team_with_match_on(day, section) }

    let(:section) { create :section }
    let(:home_team_1) { create :team, sections: [section] }
    let(:home_team_2) { create :team, sections: [section] }

    let(:day) { create :day }


    context "with no match" do
      it { is_expected.to match_array [] }
    end

    context "with one team in one match" do
      let!(:match_1) { create :match, day: day, local_team: home_team_1 }

      it { is_expected.to match_array [[home_team_1, match_1]] }
    end

    context "with two team in two different matches" do
      let!(:match_1) { create :match, day: day, local_team: home_team_1 }
      let!(:match_2) { create :match, day: day, visitor_team: home_team_2 }

      it { is_expected.to match_array [[home_team_1, match_1], [home_team_2, match_2]] }
    end

    context "with two team in one match" do
      let!(:match_1) { create :match, day: day, local_team: home_team_1, visitor_team: home_team_2 }

      it { is_expected.to match_array [[home_team_1, match_1], [home_team_2, match_1]] }
    end


  end
end
