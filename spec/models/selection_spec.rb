require 'rails_helper'

RSpec.describe Selection, :type => :model do
  it { should belong_to :user }
  it { should belong_to :match }
  it { should belong_to :team }
  it { should validate_presence_of :user }
  it { should validate_presence_of :match }
  it { should validate_presence_of :team }

end
