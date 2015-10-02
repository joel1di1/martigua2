FactoryGirl.define do
  factory :sms_notification do
    title { Faker::Lorem.sentence(4) }
    description { Faker::Lorem.sentence(20) }
    section
  end
end
