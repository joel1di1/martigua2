# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :championship do
    season { Season.current }
    calendar
    name { Faker::Company.name }
  end
end
