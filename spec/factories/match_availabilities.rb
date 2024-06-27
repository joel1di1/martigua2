# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :match_availability do
    match
    user
    available { Faker::Boolean.boolean }
  end
end
