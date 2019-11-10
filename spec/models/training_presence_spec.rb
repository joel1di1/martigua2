# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingPresence, type: :model do
  it { should validate_presence_of :training }
  it { should validate_presence_of :user }
end
