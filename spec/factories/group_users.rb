# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :group_user do
    user { create :user }
    group { create :group }
  end
end
