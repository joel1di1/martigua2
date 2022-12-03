# frozen_string_literal: true

FactoryBot.define do
  factory :user_championship_stat do
    user
    championship
  end
end
