# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar, type: :model do
  it { is_expected.to belong_to :season }
  it { is_expected.to have_many :days }
  it { is_expected.to validate_presence_of :name }
end
