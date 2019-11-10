# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SectionUserInvitation, type: :model do
  it { should validate_presence_of :section }
  it { should validate_presence_of :email }
end
