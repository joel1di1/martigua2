# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :club do
    name { "CLUB: #{Faker::Company.name}" }
  end
end
