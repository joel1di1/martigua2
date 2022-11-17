require 'rails_helper'

RSpec.describe Burn, type: :model do
  it { is_expected.to belong_to :championship }
  it { is_expected.to belong_to :user }
end
