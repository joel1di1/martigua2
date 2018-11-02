require 'rails_helper'

RSpec.describe Selection, :type => :model do
  it { should belong_to :user }
  it { should belong_to :match }
  it { should belong_to :team }
  it { should validate_presence_of :user }
  it { should validate_presence_of :match }
  it { should validate_presence_of :team }

  describe 'create' do
    context 'with previous selection' do
      let(:day) { create :day }
      let(:match_1) { create :match, day: day }
      let(:match_2) { create :match, day: day }
      let(:user) { create :user }
      let!(:previous_selection) { create :selection, user: user, match: match_1, team: match_1.local_team }

      it 'should delete old selections' do
        expect(Selection.where(user: user, match: [match_1, match_2])).to eq [previous_selection]
        new_selection = Selection.create! user: user, team: match_2.local_team, match: match_2
        expect(Selection.where(user: user, match: [match_1, match_2])).to eq [new_selection]
      end
    end
  end
end
