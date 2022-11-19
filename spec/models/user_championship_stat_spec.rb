# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserChampionshipStat do
  it { is_expected.to belong_to :championship }
end
