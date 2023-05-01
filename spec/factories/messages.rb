FactoryBot.define do
  factory :message do
    user
    channel
    content { Faker::Lorem.sentence(word_count: 10) }
    parent_message { nil }
  end
end
