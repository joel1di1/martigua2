# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :match_availability do
    match { nil }
    user { nil }
    available { false }
  end
end
