require 'rails_helper'

RSpec.describe Team, :type => :model do
  it { should validate_presence_of :club }
  it { should validate_presence_of :name }
end
