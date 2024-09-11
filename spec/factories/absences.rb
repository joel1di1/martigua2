# frozen_string_literal: true

FactoryBot.define do
  factory :absence do
    user
    start_at { 2.days.ago }
    end_at { 2.weeks.from_now }
    name { Absence::MOTIVES.sample }
    comment { Faker::Lorem.sentence }
  end
end
