# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Championship, type: :model do
  let(:championship) { create :championship }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to belong_to :season }
  it { is_expected.to belong_to :calendar }
  it { is_expected.to have_many :teams }
  it { is_expected.to have_many :matches }

  describe '.enroll_team!' do
    subject { championship.enroll_team!(team) }

    let(:team) { create :team }

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

    let(:team) { create :team }

    context 'with new team' do
      it { expect(subject.enrolled_teams).to match_array([]) }
    end

    context 'with already enrolled team' do
      before { championship.enroll_team!(team) }

      it { expect(subject.enrolled_teams).to match_array([]) }
    end
  end
end
