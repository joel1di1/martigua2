# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchSelection, type: :model do
  it { is_expected.to belong_to :match }
  it { is_expected.to belong_to :team }
  it { is_expected.to belong_to :user }
end
