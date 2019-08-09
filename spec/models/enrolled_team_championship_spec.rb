# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnrolledTeamChampionship, :type => :model do
  it { should validate_presence_of :team }
  it { should validate_presence_of :championship }
end
