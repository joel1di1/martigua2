require 'rails_helper'

RSpec.describe Calendar, type: :model do
  it { should belong_to :season }
  it { should validate_presence_of :season }
  it { should validate_presence_of :name }
end
