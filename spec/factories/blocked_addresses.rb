FactoryBot.define do
  factory :blocked_address do
    email { Faker::Internet.email }
  end
end
