# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Burn do
  it { is_expected.to belong_to :championship }
  it { is_expected.to belong_to :user }
end
