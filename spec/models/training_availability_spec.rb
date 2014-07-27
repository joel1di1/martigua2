require 'rails_helper'

RSpec.describe TrainingAvailability, :type => :model do
  it { should validate_presence_of :training }
  it { should validate_presence_of :user }
end
