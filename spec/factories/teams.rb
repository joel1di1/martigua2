# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :team do
    club { create  :club }
    name { Faker::Company.name }

    transient do
      with_section { nil }
    end

    after(:create) do |team, evaluator|
      team.sections << evaluator.with_section if evaluator.with_section
    end
  end
end
