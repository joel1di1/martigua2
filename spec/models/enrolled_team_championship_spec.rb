# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnrolledTeamChampionship, type: :model do
  it { should belong_to :team }
  it { should belong_to :championship }
end
