# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :training_availability do
    user
    training
  end
end
