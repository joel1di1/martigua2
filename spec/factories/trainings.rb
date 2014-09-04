# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :training do
    start_datetime { 1.day.from_now }
    end_datetime { start_datetime + 2.hours }
    location

    ignore do
      with_section nil
      with_group nil
    end

    after(:create) do |training, evaluator|
      training.sections << evaluator.with_section if evaluator.with_section
      training.groups   << evaluator.with_group if evaluator.with_group
    end
  end
end
