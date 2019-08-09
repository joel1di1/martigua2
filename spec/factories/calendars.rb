# frozen_string_literal: true

FactoryBot.define do
  factory :calendar do
    season
    name { Faker::Company.name }
  end
end
