# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamSection, type: :model do
  it { should belong_to :section }
  it { should belong_to :team }
end
