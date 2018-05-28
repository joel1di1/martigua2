FactoryBot.define do
  factory :calendar do
    season
    name { Faker::Company.name }
  end
end
