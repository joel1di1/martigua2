# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Injury do
  it { should belong_to(:user) }
end
