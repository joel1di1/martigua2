# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :championship do
    season
    name { Faker::Company.name }
  end
end
