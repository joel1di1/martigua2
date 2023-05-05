# frozen_string_literal: true

FactoryBot.define do
  factory :webpush_subscription do
    endpoint { 'MyString' }
    p256dh_key { 'MyString' }
    auth_key { 'MyString' }
    user { nil }
  end
end
