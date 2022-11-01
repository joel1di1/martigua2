# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnrolledTeamChampionship do
  it { is_expected.to belong_to :team }
  it { is_expected.to belong_to :championship }
end
