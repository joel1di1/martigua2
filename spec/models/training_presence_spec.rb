# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingPresence, type: :model do
  it { should belong_to :training }
  it { should belong_to :user }
end
