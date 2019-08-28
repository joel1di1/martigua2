# frozen_string_literal: true

FactoryBot.define do
  factory :calendar do
    season { Season.current }
    name { Faker::Company.name }
  end
end
