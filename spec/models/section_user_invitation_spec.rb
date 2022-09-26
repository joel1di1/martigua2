# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SectionUserInvitation, type: :model do
  it { should belong_to :section }
  it { should validate_presence_of :email }
end
