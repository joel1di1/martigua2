# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :team do
    club
    name { Faker::Company.name }

    transient do
      with_section { nil }
      enrolled_in { nil }
    end

    after(:create) do |team, evaluator|
      team.sections << evaluator.with_section if evaluator.with_section
      [*evaluator.enrolled_in].map { |championship| championship.enroll_team!(team) }
    end
  end
end
