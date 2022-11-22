# frozen_string_literal: true

FactoryBot.define do
  factory :match_invitation do
    match
    user
  end
end
