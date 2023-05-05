# frozen_string_literal: true

FactoryBot.define do
  factory :channel do
    section
    name { Faker::Lorem.word }
    private { Faker::Boolean.boolean }
    system { Faker::Boolean.boolean }
  end
end
