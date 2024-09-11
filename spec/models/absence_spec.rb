# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Absence do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_inclusion_of(:name).in_array(%w[Blessure Maladie Perso Travail Autre]) }
end
