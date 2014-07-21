# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :training do
    start_datetime { 1.day.from_now }
    end_datetime { start_datetime + 2.hours }
    location
  end
end
