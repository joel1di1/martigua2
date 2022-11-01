# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingPresence do
  it { is_expected.to belong_to :training }
  it { is_expected.to belong_to :user }
end
