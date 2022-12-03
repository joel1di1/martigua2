# frozen_string_literal: true

FactoryBot.define do
  factory :championship_group do
    name { Faker::Company.name }
  end
end
