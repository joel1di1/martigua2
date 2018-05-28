# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :admin_user do
    email { Faker::Internet::email }
    password 'secret'
  end
end
