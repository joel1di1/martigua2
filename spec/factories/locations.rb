# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    name { Faker::Address.city }
    address { Faker::Address.street_address }
  end
end
