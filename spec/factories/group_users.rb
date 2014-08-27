# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group_user do
    user { create :user }
    group { create :group }
  end
end
