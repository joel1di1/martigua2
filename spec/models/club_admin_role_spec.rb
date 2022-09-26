# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClubAdminRole, type: :model do
  it { should belong_to :club }
  it { should belong_to :user }
  it { should validate_presence_of :name }
end
