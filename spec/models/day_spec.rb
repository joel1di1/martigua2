require 'rails_helper'

RSpec.describe Day, :type => :model do
  it { should belong_to :season }
  it { should have_many :matches }

  it { should validate_presence_of :name }
  it { should validate_presence_of :season }  
  
end
