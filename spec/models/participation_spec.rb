# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Participation, type: :model do
  it { should validate_presence_of :user }
  it { should validate_presence_of :season }
  it { should validate_presence_of :section }
  it { should validate_presence_of :role }
end
