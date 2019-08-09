# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClubAdminRole, :type => :model do
  it { should validate_presence_of :club }
  it { should validate_presence_of :user }
  it { should validate_presence_of :name }
end
