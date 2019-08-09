# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :section_user_invitation do
    section
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }
    roles { [Participation::COACH, Participation::PLAYER, "#{Participation::COACH}, #{Participation::PLAYER}"].sample }
  end
end
