# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :training do
    start_datetime { Season.current.start_date + rand(200) }
    end_datetime { start_datetime + 2.hours }
    location

    transient do
      with_section { nil }
      with_group { nil }
    end

    after(:create) do |training, evaluator|
      training.sections << evaluator.with_section if evaluator.with_section
      training.groups   << evaluator.with_group if evaluator.with_group
    end
  end
end
