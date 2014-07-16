# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :section do
    club
    name { Faker::Company.name }
  end
end
