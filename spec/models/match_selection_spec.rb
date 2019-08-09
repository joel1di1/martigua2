# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchSelection, :type => :model do
  it { should belong_to :match }
  it { should belong_to :team }
  it { should belong_to :user }
end
