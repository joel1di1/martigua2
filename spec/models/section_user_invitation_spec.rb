# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SectionUserInvitation do
  it { is_expected.to belong_to :section }
  it { is_expected.to validate_presence_of :email }
end
