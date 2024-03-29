# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamSection do
  it { is_expected.to belong_to :section }
  it { is_expected.to belong_to :team }
end
