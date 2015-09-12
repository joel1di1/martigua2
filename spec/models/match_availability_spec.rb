require 'rails_helper'

RSpec.describe MatchAvailability, :type => :model do
  it { should belong_to :match }
  it { should belong_to :user }
end
