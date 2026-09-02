# frozen_string_literal: true

FactoryBot.define do
  factory :user_contact_email do
    user
    email { Faker::Internet.email }
    label { %w[Maman Papa Tuteur].sample }
  end
end
