# frozen_string_literal: true

FactoryBot.define do
  factory :day do
    calendar
    name { Faker::App.name }
    period_start_date { '2015-09-12' }
    period_end_date { '2015-09-12' }
  end
end
