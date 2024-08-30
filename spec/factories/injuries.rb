# frozen_string_literal: true

FactoryBot.define do
  factory :injury do
    user
    start_at { 2.days.ago }
    end_at { 2.weeks.from_now }
    name { Faker::Name.name }
    comment { Faker::Lorem.sentence }
  end
end
