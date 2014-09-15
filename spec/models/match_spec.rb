require 'rails_helper'

RSpec.describe Match, :type => :model do
  it { should belong_to :local_team }
  it { should belong_to :visitor_team }
end
