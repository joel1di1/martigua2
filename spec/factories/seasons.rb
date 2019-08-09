# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :season do
    start_date { (1..10).to_a.sample.years.ago }
    end_date { start_date + 1.year }
    name { "#{start_date.year}-#{end_date.year}" }
  end
end
