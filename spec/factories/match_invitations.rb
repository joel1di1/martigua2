# frozen_string_literal: true

FactoryBot.define do
  factory :match_invitation do
    match { nil }
    user { nil }
  end
end
