# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :match do
    championship
    local_team { create :team }
    visitor_team { create :team }
    start_datetime { 1.week.from_now }
    end_datetime { 1.week.from_now + 2.hours }
    local_score { 1 }
    visitor_score { 1 }
    location { nil }
    meeting_datetime { "2014-09-14 22:05:02" }
    meeting_location { "MyString" }
    day
  end
end
