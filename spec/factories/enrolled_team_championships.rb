# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :enrolled_team_championship do
    team { nil }
    championship { nil }
  end
end
