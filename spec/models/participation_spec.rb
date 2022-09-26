# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Participation, type: :model do
  it { should belong_to :user }
  it { should belong_to :season }
  it { should belong_to :section }
  it { should validate_presence_of :role }
end
