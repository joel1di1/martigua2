# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :section do
    club
    name { "SECTION #{Faker::Company.name}" }
  end
end
