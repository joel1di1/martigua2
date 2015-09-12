# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :match do
    championship
    local_team { create :team }
    visitor_team { create :team }
    start_datetime { 1.week.from_now }
    end_datetime { 1.week.from_now + 2.hours }
    prevision_period_start { 1.week.from_now - 1.day }
    prevision_period_end { 1.week.from_now + 2.days }
    local_score 1
    visitor_score 1
    location nil
    meeting_datetime "2014-09-14 22:05:02"
    meeting_location "MyString"
  end
end
