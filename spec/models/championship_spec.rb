require 'rails_helper'

RSpec.describe Championship, :type => :model do
  it { should validate_presence_of :name }
  it { should validate_presence_of :season }
  it { should have_many :teams }

  let(:championship) { create :championship }

  describe '.enroll_team!' do
    let(:team) { create :team }

    subject { championship.enroll_team!(team) }

    context 'with new team' do
      it { expect(subject.enrolled_teams).to match_array([team]) } 
    end
    context 'with already enrolled team' do
      before { championship.enroll_team!(team) }
      it { expect(subject.enrolled_teams).to match_array([team]) } 
    end
  end

end
