FactoryBot.define do
  factory :user_channel_message do
    user { nil }
    channel { nil }
    message { nil }
    read { false }
  end
end
