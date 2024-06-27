# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :enrolled_team_championship do
    team
    championship
  end
end
