# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :selection do
    user
    match
    team
  end
end
