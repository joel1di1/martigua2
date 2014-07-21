require 'rails_helper'

RSpec.describe Location, :type => :model do
  it { should validate_presence_of :name }
end
