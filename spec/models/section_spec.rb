require 'rails_helper'

RSpec.describe Section, :type => :model do
  it { should validate_presence_of :club }
  it { should validate_presence_of :name }
  it { should have_many :teams }
  it { should have_many :participations }
  it { should have_many :users }

  let(:section) { create :section }

  describe '#add_player' do 
    subject { section.add_player(user) }

    context 'with a new player' do
      let(:user) { create :user }

      it { expect(subject.players).to match_array([user]) }
    end
  end
end
