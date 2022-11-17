# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Discussion do
  it { is_expected.to belong_to :section }
end
