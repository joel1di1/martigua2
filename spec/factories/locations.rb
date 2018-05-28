# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :location do
    name { Faker::Address.city }
    address { Faker::Address.street_address }
  end
end
