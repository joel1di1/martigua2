# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :section do
    club
    name { "SECTION #{Faker::Company.name}"}
  end
end
