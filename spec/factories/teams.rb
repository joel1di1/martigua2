# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do
    club { create  :club }
    name { Faker::Company.name }
  end
end
