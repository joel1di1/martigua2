# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Championship do
  let(:championship) { create(:championship) }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to belong_to :season }
  it { is_expected.to belong_to :calendar }
  it { is_expected.to have_many :teams }
  it { is_expected.to have_many :matches }

  describe '.enroll_team!' do
    subject { championship.enroll_team!(team) }

    let(:team) { create(:team) }

    context 'with new team' do
      it { expect(subject.enrolled_teams).to match_array([team]) }
    end

    context 'with already enrolled team' do
      before { championship.enroll_team!(team) }

      it { expect(subject.enrolled_teams).to match_array([team]) }
    end
  end

  describe '#unenroll_team!' do
    subject { championship.unenroll_team!(team) }

    let(:team) { create(:team) }

    context 'with new team' do
      it { expect(subject.enrolled_teams).to match_array([]) }
    end

    context 'with already enrolled team' do
      before { championship.enroll_team!(team) }

      it { expect(subject.enrolled_teams).to match_array([]) }
    end
  end

  describe '.create_from_ffhb!' do
    subject(:create_championship) do
      Championship.create_from_ffhb!(code_pool:, code_division:, code_comite:, type_competition:)
    end

    before { mock_ffhb }

    let(:type_competition) { 3 }
    let(:code_comite) { 123 }
    let(:code_division) { 20_570 }
    let(:code_pool) { 110_562 }

    it { expect { create_championship }.to change(Championship, :count).by(1) }
    it { expect { create_championship }.to change(Calendar, :count).by(1) }
    it { expect(create_championship.name).to eq '2EME DTM 44' }
    it { expect { create_championship }.to change(Day, :count).by(22) }

    it { expect { create_championship }.to change(Team, :count).by(12) }

    it "\n\t\t!!!! faire en sorte que martigua 1 soit rattaché a Martigua SLC\n"

    context 'with incorrect pool code' do
      let(:code_pool) { 123 }

      it do
        expect { create_championship }.to raise_error(RuntimeError, 'Could not find pool with id 123')
      end
    end
  end
end
