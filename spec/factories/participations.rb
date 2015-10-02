# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :participation do
    user
    section
    season { Season.current }
    role { [Participation::PLAYER, Participation::COACH].sample }
    trait :coach do
      role Participation::COACH
    end
    trait :player do
      role Participation::PLAYER
    end
  end
end
