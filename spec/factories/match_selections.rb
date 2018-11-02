# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :match_selection do
    match { nil }
    team { "" }
    user { nil }
  end
end
