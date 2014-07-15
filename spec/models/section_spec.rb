require 'rails_helper'

RSpec.describe Section, :type => :model do
  it { should validate_presence_of :club }
  it { should validate_presence_of :name }
  it { should have_many :teams }
end
