# frozen_string_literal: true

FactoryBot.define do
  factory :user_championship_stat do
    user { nil }
    championship { nil }
    matchs { 1 }
    goals { 1 }
    saves { 1 }
    goal_average { 1 }
    save_average { 1 }
  end
end
