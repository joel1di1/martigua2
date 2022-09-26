# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar, type: :model do
  it { should belong_to :season }
  it { should have_many :days }
  it { should validate_presence_of :name }
end
