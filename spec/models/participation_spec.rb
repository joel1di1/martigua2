# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Participation do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :season }
  it { is_expected.to belong_to :section }
  it { is_expected.to validate_presence_of :role }
end
