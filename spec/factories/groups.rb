# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    name { Faker::Company.name}
    description { Faker::Lorem.sentence }
    section { create :section }
    color { Faker::Number.number(6) }
  end
end
