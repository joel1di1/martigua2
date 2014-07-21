require 'rails_helper'

RSpec.describe Training, :type => :model do
  it { should validate_presence_of :start_datetime }
  it { should have_and_belong_to_many :sections }
end
