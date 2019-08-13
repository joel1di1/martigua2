# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :group do
    name { Faker::Company.name }
    description { Faker::Lorem.sentence }
    section { create :section }
    season { Season.current }
    color { Faker::Number.number(digits: 6) }
  end
end
