# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DutyTask, type: :model do
  it { should belong_to :user }
  it { should validate_presence_of :name }
end
