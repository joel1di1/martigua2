# frozen_string_literal: true

FactoryBot.define do
  factory :sms_notification do
    title { Faker::Lorem.sentence(word_count: 4) }
    description { Faker::Lorem.sentence(word_count: 20) }
    section
  end
end
