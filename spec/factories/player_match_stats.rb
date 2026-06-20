# frozen_string_literal: true

FactoryBot.define do
  factory :player_match_stat do
    match
    player_id { Faker::Number.number(digits: 13).to_s }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name.upcase }
    jersey_number { rand(1..99) }
    captain { false }
    goals { rand(0..10) }
    seven_meters { rand(0..3) }
    shots { rand(0..15) }
    saves { 0 }
    warnings { rand(0..1) }
    two_minutes { rand(0..3) }
    disqualifications { 0 }
  end
end
