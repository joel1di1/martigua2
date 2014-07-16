# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :participation do
    user
    section
    season { Season.current }
    role { ['player', 'coach'].sample }
  end
end
