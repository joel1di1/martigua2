# frozen_string_literal: true

FactoryBot.define do
  factory :day do
    calendar
    name { Faker::App.name }
    period_start_date { Faker::Date.between(from: 2.weeks.ago, to: 2.weeks.from_now) }
    period_end_date { period_start_date + 2.days }
  end
end
