# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :selection do
    user
    match
    team
  end
end
