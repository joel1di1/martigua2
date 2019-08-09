# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamSection, :type => :model do
  it { should validate_presence_of :section }
  it { should validate_presence_of :team }
end
