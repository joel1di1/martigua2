require 'rails_helper'

RSpec.describe Channel, type: :model do
  it { is_expected.to belong_to :section }
  it { is_expected.to belong_to(:owner).optional }
  it { is_expected.to validate_presence_of :name }
  
end
